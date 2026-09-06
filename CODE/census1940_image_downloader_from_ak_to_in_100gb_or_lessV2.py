import os
import subprocess
import shutil
import zipfile

def split_large_zip(zip_file_path, max_size_gb):
    """Split a large zip file into smaller parts, each under max_size_gb."""
    max_size_bytes = max_size_gb * (1024**3)
    
    with zipfile.ZipFile(zip_file_path, 'r') as zf:
        file_infos = zf.infolist()
        
        part_num = 1
        current_size = 0
        part_files = []
        
        base_name = os.path.splitext(zip_file_path)[0]

        for file_info in file_infos:
            current_size += file_info.file_size
            part_files.append(file_info.filename)

            if current_size > max_size_bytes:
                part_zip_path = f"{base_name}_part{part_num}.zip"
                with zipfile.ZipFile(part_zip_path, 'w', zipfile.ZIP_DEFLATED) as part_zip:
                    for part_file in part_files:
                        part_zip.writestr(part_file, zf.read(part_file))
                print(f"Created split zip: {part_zip_path}")
                part_num += 1
                current_size = 0
                part_files = []

        if part_files:  # Handle remaining files
            part_zip_path = f"{base_name}_part{part_num}.zip"
            with zipfile.ZipFile(part_zip_path, 'w', zipfile.ZIP_DEFLATED) as part_zip:
                for part_file in part_files:
                    part_zip.writestr(part_file, zf.read(part_file))
            print(f"Created split zip: {part_zip_path}")

    os.remove(zip_file_path)  # Remove the original large zip

def create_split_zips(folder_path, base_zip_name, max_zip_size_gb):
    """Create split zip files from a folder with size limit per zip file."""
    max_size_bytes = max_zip_size_gb * (1024**3)
    current_size = 0
    part_num = 1
    current_zip_path = f"{base_zip_name}_part{part_num}.zip"
    current_zip = zipfile.ZipFile(current_zip_path, 'w', zipfile.ZIP_DEFLATED)

    print(f"Creating new zip: {current_zip_path}")

    for root, _, files in os.walk(folder_path):
        for file in files:
            file_path = os.path.join(root, file)
            file_size = os.path.getsize(file_path)

            if file_size > max_size_bytes:
                print(f"Skipping {file_path}: file size exceeds max zip size.")
                continue

            if current_size + file_size > max_size_bytes:
                current_zip.close()
                print(f"Completed zip: {current_zip_path}")
                part_num += 1
                current_zip_path = f"{base_zip_name}_part{part_num}.zip"
                current_zip = zipfile.ZipFile(current_zip_path, 'w', zipfile.ZIP_DEFLATED)
                print(f"Creating new zip: {current_zip_path}")
                current_size = 0

            arcname = os.path.relpath(file_path, folder_path)
            current_zip.write(file_path, arcname=arcname)
            current_size += file_size

    current_zip.close()
    print(f"Completed zip: {current_zip_path}")

def download_and_zip_1940_census_images(destination_base_path, aws_bucket_url, state_abbreviations, max_zip_size_gb=90):
    for state in state_abbreviations:
        # Define the destination folder for each state
        destination_folder = os.path.join(destination_base_path, state)
        base_zip_name = os.path.join(destination_base_path, state)

        # Create the destination folder if it does not exist
        if not os.path.exists(destination_folder):
            os.makedirs(destination_folder)
            print(f"Created folder: {destination_folder}")

        # Construct the AWS S3 sync command
        command = [
            "aws", "s3", "sync",
            f"{aws_bucket_url}/{state}/",  # Source path on S3
            f"{destination_folder}/",  # Destination folder
            "--no-sign-request"  # Option to not use signed requests
        ]

        # Execute the command
        try:
            print(f"Downloading images for state: {state}")
            subprocess.run(command, check=True)
            print(f"Download completed for state: {state}")

            # Create split zips for the folder
            print(f"Zipping and splitting folder for state: {state}")
            create_split_zips(destination_folder, base_zip_name, max_zip_size_gb)

            # Remove the unzipped folder to save space
            shutil.rmtree(destination_folder)
            print(f"Removed unzipped folder for state: {state}")

        except subprocess.CalledProcessError as e:
            print(f"Error occurred while downloading images for state {state}: {e}")
        except Exception as e:
            print(f"Error occurred while processing state {state}: {e}")

# Define parameters
destination_base_path = r"C:/Users/ilmyo/OneDrive/Desktop/1940_census_image"
aws_bucket_url = "s3://nara-1940-census/population-schedules"
state_abbreviations = [
    "il"
]

# Run the function
download_and_zip_1940_census_images(destination_base_path, aws_bucket_url, state_abbreviations)

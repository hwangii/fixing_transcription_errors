import os
import zipfile
import shutil

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

def zip_existing_images(source_folder_path, output_base_path, max_zip_size_gb=90, remove_original=False):
    """
    Zip an existing folder of images into split zip files.
    
    Args:
        source_folder_path: Path to the folder containing images to zip
        output_base_path: Base path and name for the output zip files
        max_zip_size_gb: Maximum size per zip file in GB (default: 90)
        remove_original: Whether to remove the original folder after zipping (default: False)
    """
    if not os.path.exists(source_folder_path):
        print(f"Error: Source folder does not exist: {source_folder_path}")
        return
    
    print(f"Zipping folder: {source_folder_path}")
    print(f"Output base name: {output_base_path}")
    print(f"Max zip size: {max_zip_size_gb} GB")
    
    # Create split zips for the folder
    create_split_zips(source_folder_path, output_base_path, max_zip_size_gb)
    
    if remove_original:
        shutil.rmtree(source_folder_path)
        print(f"Removed original folder: {source_folder_path}")
    
    print("Zipping completed!")

# Example usage - modify these paths for your needs
if __name__ == "__main__":
    # Path to your existing folder containing images
    source_folder = r"D:/census1930_image_download_continued/United States Census 1930/Wisconsin"
    
    # Base name for output zip files (will create il_part1.zip, il_part2.zip, etc.)
    output_base = r"D:/census1930_image_download_continued/United States Census 1930/wi1930_zipped"
    
    # Maximum size per zip file in GB
    max_size_gb = 90
    
    # Whether to remove the original folder after zipping (be careful with this!)
    remove_original_folder = False
    
    # Run the zipping function
    zip_existing_images(source_folder, output_base, max_size_gb, remove_original_folder)

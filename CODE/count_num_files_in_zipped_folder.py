import zipfile

def count_files_in_zip(zip_path):
    """
    Counts the number of files in a zipped folder.
    
    Parameters:
        zip_path (str): Path to the zip file.
        
    Returns:
        int: Number of files in the zip file.
    """
    try:
        with zipfile.ZipFile(zip_path, 'r') as zip_ref:
            # List all files and folders in the zip
            all_files = zip_ref.namelist()
            # Count files (ignoring folders)
            file_count = sum(1 for item in all_files if not item.endswith('/'))
        return file_count
    except Exception as e:
        print(f"Error: {e}")
        return 0

# Example usage
zip_file_path = 'D:/Dropbox/fixing_transcription_errors/DATA/INTERMEDIATE/wi1930_zipped_part2.zip'  # Replace with your zip file path
print(f"Number of files in the zip: {count_files_in_zip(zip_file_path)}")

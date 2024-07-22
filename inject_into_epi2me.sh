
TARGET_FOLDER="/home/dami/epi2melabs/workflows/da-i/epi2melabs-test/"


# Remove the contents and replace with the files in the current folder
echo "Removing $TARGET_FOLDER contents..."
sudo rm -rf "$TARGET_FOLDER*"

echo "Done"
echo "Injecting $(pwd) into $TARGET_FOLDER ..."
sudo cp -r "$(pwd)/" "$TARGET_FOLDER/"

echo "Done"

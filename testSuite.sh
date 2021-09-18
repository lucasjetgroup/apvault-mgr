# For manual testing of new features

# create test files
mkdir -p test/Videos/Models/ModelName1/Videos/
mkdir -p test/Videos/Models/ModelName2/Vids
mkdir -p test/Videos/Models/ModelName2/screens
mkdir -p test/Videos/Studios/StudioName1
mkdir -p test/Videos/Studios/StudioName2

#files should survive
touch test/Videos/Models/ModelName1/legit-video.mp4
touch test/Videos/Models/ModelName1/actual-porn.mp4
touch test/Videos/Models/ModelName1/do-not-delete.mp4
#file should be flattened
touch test/Videos/Models/ModelName1/Videos/legit.mp4

#files should be destroyed
touch test/Videos/Models/ModelName1/vomit-gangbang.jpg
touch test/Videos/Models/ModelName1/screens.mp4.jpg

#files should survive
touch test/Videos/Models/ModelName2/legit-video.mp4
touch test/Videos/Models/ModelName2/actual-porn.mp4
touch test/Videos/Models/ModelName2/do-not-delete.mp4

#files should be flattened except for dupe
touch test/Videos/Models/ModelName2/duplicate-name.mp4
touch test/Videos/Models/ModelName2/Vids/legit.mp4
touch test/Videos/Models/ModelName2/Vids/duplicate-name.mp4

#files should be destroyed
touch test/Videos/Models/ModelName2/vomit-gangbang.jpg

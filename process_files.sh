#!/bin/bash

# Resilience Academy GeoNode customisation script
#
# Usually this file does not need to be executed manually.
# 
# Execute update.sh that will pull latest changes from git
# and execute this script afterwards.
#
# If you modify files list please keep the custom css file
# first or file verification check might not give planned
# results. New files should be added at the bottom of the
# lists.
#
# This file is supposed to be more readable and simple
# than efficient and smart. Please keep it that way.
#
# softdev@utu.fi

# Directory to store the backups
BACKUPS='backups'

# Temporary direction for backup creation
TMP='tmp'

# Image files path
IMAGES='images'

# Image path inside container
CONTAINER_IMAGE_PATH='/usr/src/geonode/geonode/static/geonode/img'

# File names inside container
CONTAINER_FILES=(
  'resilience-academy.css'      #  0 (does not exist inside container on first run)
  'base.html'                   #  1
  'index.html'                  #  2
  '_resourcebase_snippet.html'  #  3
  '_search_content.html'        #  4
  'layer_list.html'             #  5
  '_search_user_content.html'   #  6
  '_general_filters.html'       #  7
  'cart.html'                   #  8
  '_text_filter.html'           #  9
  '_type_filters.html'          # 10
  'admin.py'                    # 11
  'forms.py'                    # 12 !
  'forms.py'                    # 13 !
  'about.html'                  # 14
  '_resourcebase_info_panel.html' #15
  '_resourcebase_contact_snippet.html' #16
  'layer_detail.html'           #17
   )
   
# File paths inside container
CONTAINER_PATHS=(
  '/usr/src/geonode/geonode/static/geonode/css/'                #  0
  '/usr/src/geonode/geonode/templates/'                         #  1
  '/usr/src/geonode/geonode/templates/'                         #  2
  '/usr/src/geonode/geonode/base/templates/base/'               #  3
  '/usr/src/geonode/geonode/templates/search/'                  #  4
  '/usr/src/geonode/geonode/layers/templates/layers/'           #  5
  '/usr/src/geonode/geonode/templates/search/'                  #  6
  '/usr/src/geonode/geonode/templates/search/'                  #  7
  '/usr/src/geonode/geonode/static/geonode/js/templates/'       #  8
  '/usr/src/geonode/geonode/templates/search/'                  #  9
  '/usr/src/geonode/geonode/templates/search/'                  # 10
  '/usr/src/geonode/geonode/people/'                            # 11
  '/usr/local/lib/python2.7/site-packages/django/contrib/auth/' # 12
  '/usr/src/geonode/geonode/people/'                            # 13
  '/usr/src/geonode/geonode/templates/'                         # 14
  '/usr/src/geonode/geonode/base/templates/base/'               # 15
  '/usr/src/geonode/geonode/base/templates/base/'               # 16
  '/usr/src/geonode/geonode/layers/templates/layers/'           # 17
  )
  
  
# File names outside container (here)
# This is needed because there are files with same name on different path
LOCAL_FILES=(
  'resilience-academy.css'      #  0
  'base.html'                   #  1
  'index.html'                  #  2
  '_resourcebase_snippet.html'  #  3
  '_search_content.html'        #  4
  'layer_list.html'             #  5
  '_search_user_content.html'   #  6
  '_general_filters.html'       #  7
  'cart.html'                   #  8
  '_text_filter.html'           #  9
  '_type_filters.html'          # 10
  'admin.py'                    # 11
  'django-forms.py'             # 12
  'geonode-forms.py'            # 13
  'about.html'                  # 14
  '_resourcebase_info_panel.html' #15
  '_resourcebase_contact_snippet.html' #16
  'layer_detail.html'           #17
  )

# Image files, these are not backed up but existence is checked
IMAGE_FILES=(
  'ARU-logo.jpg'
  'dar.jpg'
  'Government-of-Tanzania-Logo.png'
  'RA-Shield_Horizantal.png'
  'SUA_logo.png'
  'SUZA_Logo.png'
  'The-World-Bank-logo.png'
  'TURP-Logo.png'
  'UDSM_logo.png'
  'UKaid-Logo.png'
  'University-of-Turku-logo.png'
  'UTU.png'
  'Web_RA-logo-2.png'
  'zanzibar.jpg'    # old jumbotron - will be removed
  'jumbotron-2020-01-16-1723x800.jpg'
  'ra.png'
  'assessment.png'
  'ramani_huria.png'
  'favicon.ico'
  )

# Get django container id
CONTAINER=$(docker ps -aqf "name=django4resilienceacademy")

# Exit if django container is not found
if [ -z "$CONTAINER" ]; then
  echo "No django container found. Halting script exection."
  exit 1
fi

# Create backups directory if it does not exist
if [ ! -d "$BACKUPS" ]; then
  mkdir "$BACKUPS"
fi

# Remove temp directory if it exists already
if [ -d "$TMP" ]; then
  echo "Temp directory $TMP already exists. Removing it before creating a new one."
  rm -rf "$TMP"
fi

# Create the temp directory
mkdir "$TMP"

# Copy all container files to local temp and ensure that file exists (exit if not)
for ((i = 0; i < ${#CONTAINER_FILES[@]};++i)); do
  
  # Copy file to temp directory
  docker cp $CONTAINER:${CONTAINER_PATHS[$i]}${CONTAINER_FILES[$i]} $TMP/${LOCAL_FILES[$i]}
  
  # Check every file but the first (custom CSS) and exit if it does not exist
  if [ ! -s "$TMP/${LOCAL_FILES[$i]}" ]; then
    if (($i > 0)); then
      echo "Copied file $i: $CONTAINER:${CONTAINER_PATHS[$i]}${CONTAINER_FILES[$i]} -> $TMP/${LOCAL_FILES[$i]} is empty or does not exist! Halting script exection."
      exit 1
    else
      echo "Custom CSS file: $TMP/${LOCAL_FILES[$i]} not found on container - continue running script"
    fi
  #else
  #  echo "Successfully copied file $i: $CONTAINER:${CONTAINER_PATHS[$i]}${CONTAINER_FILES[$i]} -> $TMP/${LOCAL_FILES[$i]}"
  fi
  
done

# Create a zip file from backups
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")
zip -rq "$BACKUPS/ra-originals-$TIMESTAMP.zip" "$TMP"

# Check that the zip file is found
if [ ! -s "$BACKUPS/ra-originals-$TIMESTAMP.zip" ]; then
  echo "Created backup $BACKUPS/ra-originals-$TIMESTAMP.zip is missing! Halting script exection.."
  exit 1
fi

# Check that every customisation file exists locally and is not empty
for ((i = 0; i < ${#CONTAINER_FILES[@]};++i)); do
  if [ ! -s "${LOCAL_FILES[$i]}" ]; then
    echo "Required customisation file ${LOCAL_FILES[$i]} is empty or does not exist! Halting script exection."
    exit 1
  fi
done

# Check that every image file exists locally and is not empty
for ((i = 0; i < ${#IMAGE_FILES[@]};++i)); do
  if [ ! -s "$IMAGES/${IMAGE_FILES[$i]}" ]; then
    echo "Required image file ${IMAGE_FILES[$i]} is empty or does not exist! Halting script exection."
    exit 1
  fi
done

# Update container files
for ((i = 0; i < ${#CONTAINER_FILES[@]};++i)); do
  # Copy file to container
  docker cp ${LOCAL_FILES[$i]} $CONTAINER:${CONTAINER_PATHS[$i]}${CONTAINER_FILES[$i]}
done

# Update container images
for ((i = 0; i < ${#IMAGE_FILES[@]};++i)); do
  # Copy image to container
  docker cp $IMAGES/${IMAGE_FILES[$i]} $CONTAINER:${CONTAINER_IMAGE_PATH}/${IMAGE_FILES[$i]}
done

# Remove temp directory
rm -rf "$TMP"

# Run 'collectstatic' management command
docker exec -it $CONTAINER bash -c "/usr/src/resilienceacademy/manage.sh collectstatic --noinput"

# Restart django container to show customisation (test without)
# echo "Restarting django container, this will take some seconds"
# docker restart "$CONTAINER"

# Tell user that customisation is up to date
echo "Customisation update ready."

echo "Restart the django container if updates are not showing up"

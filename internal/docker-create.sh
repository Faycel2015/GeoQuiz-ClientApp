sudo docker create \
--privileged \
-it \
-p 8080:8080 \
--mount type=bind,source="$(pwd)",target=/home/developer/app \
--mount type=bind,source=/dev/bus/usb,target=/dev/bus/usb \
-P \
--name geoquiz-app-container \
romainguillot/geoquiz-app \
bash

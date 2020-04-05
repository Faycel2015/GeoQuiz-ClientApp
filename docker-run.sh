sudo docker run \
--privileged \
-it \
-p 8080:8080 \
--mount type=bind,source="$(pwd)",target=/home/developer/app \
--mount type=bind,source=/dev/bus/usb,target=/dev/bus/usb \
-P \
geoquiz_docker \
bash

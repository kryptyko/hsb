#!/bin/sh

choice=$(dialog \
   --input-fd  2 \
   --output-fd 1 \
   --menu main 10 40 5 1 A 2 B \
)

case "$choice" in
   1)
      choiceA=$(dialog --input-fd 2 --output-fd 1 --menu sub-A 10 30 5 1 A1 2 A2)
      ;;
   2)
      choiceB=$(dialog --input-fd 2 --output-fd 1 --menu sub-B 10 30 5 1 B1 2 B2)
      ;;
esac

stty sane
clear
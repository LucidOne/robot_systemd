setup="/etc/ros/environment
       $HOME/.ros/environment
"

for file in $setup; do
    [ -f $file ] || continue
    . $file
done

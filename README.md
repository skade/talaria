# Talaria

The flying shoes of Hermes. A shoes4 application to control AR.Drones.

![Hermes Shoes](http://upload.wikimedia.org/wikipedia/commons/b/bd/The_Arming_of_Perseus_1885_Edward_Burne-Jones.jpg)

## Usage

* Acquire an [AR.Drone 2.0](http://ardrone2.parrot.com)
* Make sure you have jruby-1.7.4 installed and activated in your shell
* Clone the current shoes4 development branch and talaria:

```
git clone git@github.com:shoes/shoes4.git
git clone git@github.com:skade/talaria.git
```

* Install both bundles:

```
cd shoes4
bundle install
cd ..
cd talaria
bundle install
```

* Make sure `ffmpeg` is in your `$PATH`. Mac users can use the binary found [here](http://ffmpegmac.net/) or install using [homebrew](http://brew.sh/).
* Join your drones wifi network.
* Run

```
cd shoes4
bin/shoes ../talaria/talaria.rb
```

* Fly and enjoy the view!

## Key configuration

The key configuration is built for indoor control and immediately stops the drone if no key is pressed. The current key configuration is:

* `t`: take off
* `g`: land
* `<SPACE>`: emergency toggle (immediately switches of the drone!)
* `c`: switch camera signal between front and bottom camera

* `<UP>`: fly upwards
* `<DOWN>`: fly downwards
* `<LEFT>`: turn left
* `<RIGHT>`: turn right

* `w`: forward
* `s`: backward
* `a`: bank left
* `d`: bank right

* `h`: flip left (not implemented)
* `j`: flip backward (not implemented)
* `k`: flip forward (not implemented)
* `l`: flip right (not implemented)

## Controller Support

Talaria has support for PS3 controllers through `javahidapi`. To connect a controller to OS X, see [this gist](https://gist.github.com/statico/3172711). Linux should behave similar. The controller will be automatically detected if present.

Configuration:

* `L2`: take off
* `R2`: land
* `X`: emergency togle
* `L1`: front camera
* `R1`: bottom camera

* `left analog stick`: forward/backward, bank left/right
* `right analog stick`: up/down, turn left/right

* `d-pad`: flips (not implemented)

## Warning

When playing around, lower the speed settings in `lib/indoor_control.rb`. If your app crashes, the drone remembers the last settings and will be flying in the last direction without control.

Also, try the emergency toggle right after first take off to get a feel for it.

## Pull requests

As long as Travis does not support drones and external controllers, I accept pull requests in good faith for just about anything.

## License

MIT, see LICENSE.md for details.

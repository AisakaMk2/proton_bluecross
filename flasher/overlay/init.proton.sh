#!/system/bin/sh
# Proton Kernel init helper script

# Helpers
little_max() { echo $1 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq; }
big_max() { echo $1 > /sys/devices/system/cpu/cpu4/cpufreq/scaling_max_freq; }
little_min() { echo $1 > /sys/module/cpu_input_boost/parameters/remove_input_boost_freq_lp; }
big_min() { echo $1 > /sys/module/cpu_input_boost/parameters/remove_input_boost_freq_perf; }
little_boost() { echo $1 > /sys/module/cpu_input_boost/parameters/input_boost_freq_lp; }
big_boost() { echo $1 > /sys/module/cpu_input_boost/parameters/input_boost_freq_hp; }
little_general_boost() { echo $1 > /sys/module/cpu_input_boost/parameters/general_boost_freq_lp; }
big_general_boost() { echo $1 > /sys/module/cpu_input_boost/parameters/general_boost_freq_hp; }
little_gov_param() { echo $2 > /sys/devices/system/cpu/cpu0/cpufreq/$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)/$1; }
big_gov_param() { echo $2 > /sys/devices/system/cpu/cpu4/cpufreq/$(cat /sys/devices/system/cpu/cpu4/cpufreq/scaling_governor)/$1; }
gov_param() { little_gov_param $1 $2; big_gov_param $1 $2; }
boost_duration() { echo $1 > /sys/module/cpu_input_boost/parameters/input_boost_duration; }
boost_timeout() { echo $1 > /sys/module/cpu_input_boost/parameters/frame_boost_timeout; }
stune_boost() { echo $1 > /sys/module/cpu_input_boost/parameters/dynamic_stune_boost; }
stune_general_boost() { echo $1 > /sys/module/cpu_input_boost/parameters/general_stune_boost; }
gpu_min() { echo $1 > /sys/class/kgsl/kgsl-3d0/devfreq/min_freq; }

# Actions
case "$1" in
### USB Functions ###
	'usb_msc')
		rm -f /config/usb_gadget/g1/configs/b.1/function0
		ln -s /config/usb_gadget/g1/functions/mass_storage.0 /config/usb_gadget/g1/configs/b.1/function0
		echo msc > /config/usb_gadget/g1/configs/b.1/strings/0x409/configuration
		echo $(getprop sys.usb.controller) > /config/usb_gadget/g1/UDC
		setprop sys.usb.state $(getprop sys.usb.config)
		;;
### Profiles ###
	'battery')
		# CPU: Little
		little_min 300000
		little_max 1516800
		little_boost 748800
		little_general_boost 652800
		little_gov_param hispeed_freq 0
		# CPU: Big
		big_max 1209600
		big_boost 0
		big_general_boost 0
		big_gov_param hispeed_freq 0
		# CPU: Governor
		gov_param hispeed_load 100
		gov_param iowait_boost_enable 0
		gov_param up_rate_limit_us 2000
		gov_param down_rate_limit_us 4000
		# CPU: Boost
		stune_boost 15
		stune_general_boost 1
		boost_duration 32
		boost_timeout 1750

		# GPU
		gpu_min 180000000
		gpu_gov msm-adreno-tz
		;;
	'balanced')
		# CPU: Little
		little_min 300000
		little_max 1766400
		little_boost 825600
		little_general_boost 748800
		little_gov_param hispeed_freq 0
		# CPU: Big
		big_max 2323200
		big_boost 902400
		big_general_boost 825600
		big_gov_param hispeed_freq 0
		# CPU: Governor
		gov_param hispeed_load 90
		gov_param iowait_boost_enable 0
		gov_param up_rate_limit_us 500
		gov_param down_rate_limit_us 20000
		# CPU: Boost
		stune_boost 25
		stune_general_boost 10
		boost_duration 64
		boost_timeout 3250

		# GPU
		gpu_min 180000000
		gpu_gov msm-adreno-tz
		;;
	'performance')
		# CPU: Little
		little_min 576000
		little_max 1766400
		little_boost 1516800
		little_general_boost 1132800
		little_gov_param hispeed_freq 1228800
		# CPU: Big
		big_max 2803200
		big_boost 1363200
		big_general_boost 1209600
		big_gov_param hispeed_freq 1363200
		# CPU: Governor
		gov_param hispeed_load 15
		gov_param iowait_boost_enable 1
		gov_param up_rate_limit_us 400
		gov_param down_rate_limit_us 25000
		# CPU: Boost
		stune_boost 50
		stune_general_boost 25
		boost_duration 125
		boost_timeout 15000

		# GPU
		gpu_min 342000000
		gpu_gov msm-adreno-tz
		;;
	'turbo')
		# CPU: Little
		little_min 576000
		little_max 1766400
		little_boost 1516800
		little_general_boost 1132800
		little_gov_param hispeed_freq 1228800
		# CPU: Big
		big_max 2803200
		big_boost 1363200
		big_general_boost 1209600
		big_gov_param hispeed_freq 1363200
		# CPU: Governor
		gov_param hispeed_load 15
		gov_param iowait_boost_enable 1
		# CPU: Boost
		stune_boost 50
		stune_general_boost 25
		boost_duration 125
		boost_timeout 30000

		# GPU
		gpu_min 342000000
		gpu_gov performance
		;;
	*)
		echo "Valid actions: [usb] usb_msc, [profiles] battery, balanced, performance, turbo"
		exit 1
esac

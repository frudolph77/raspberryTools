#!/bin/bash
#
#######################################################################################################################
#
# Retrieve throttling bits of Raspberry and report their semantic
#
# Throttle bit semantic according https://github.com/raspberrypi/documentation/blob/JamesH65-patch-vcgencmd-vcdbg-docs/raspbian/applications/vcgencmd.md
#
#######################################################################################################################
#
#    Copyright (c) 2019 framp at linux-tips-and-tricks dot de
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
#######################################################################################################################

m=( "Under-voltage detected" "Arm frequency capped" "Currently throttled" "Soft temperature limit active" \
""  ""  ""  ""  ""  ""  ""  ""  ""  ""  ""  "" \
"Under-voltage has occurred" "Arm frequency capped has occurred" "Throttling has occurred" "Soft temperature limit has occurred" )

function analyze() {
	b=$(perl -e "printf \"%08b\\n\", $1" 2>/dev/null) 				# convert hex number into binary number
	i=0 															# start with bit 0 (LSb)
	while [[ -n $b ]]; do											# there are still bits to process
		t=${b:${#b}-1:1} 											# extract LSb
		if (( $t != 0 )); then 										# bit set
			if (( $i <= ${#m[@]} - 1 )) && [[ -n ${m[$i]} ]]; then 	# bit meaning is defined
				echo "Bit $i set: ${m[$i]}"
			else													# bit meaning unknown
				echo "Bit $i set: meaning unknown"
			fi
		fi
		b=${b::-1} 													# remove LSb from throttle bits
		(( i++ )) 													# inc bit counter
	done
}

t=$(vcgencmd get_throttled | cut -f 2 -d "=" )
echo "Throttling in hex : $t ('occured' bits reset on boot only)"
analyze $t

t=$(vcgencmd get_throttled 0xf | cut -f 2 -d "=" )
echo "Throttling in hex: $t ('occured' bits reset after call)"
analyze $t

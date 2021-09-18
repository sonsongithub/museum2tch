#!/opt/local/bin/ruby

$localize = Hash.new
$words = Hash.new

def open( filepath )
	f = File::open( filepath, "r" )
	str = f.read
	result = str.scan(/NSLocalizedString\(.*?@\"(.*?)\".*?\)/)
	result.each{ |e|
		$words[e[0]] = ""
	}
	f.close
end

def parseLocalizableString( filepath, key )
	
	$localize[key] = Hash.new

	f = File::open( filepath, "r" )
	str = f.read
	str.each{ |line|
		if line =~ /\"(.*?)\".*=.*\"(.*?)\";/
			$localize[key][$1] = $2
			puts "#{key}=>#{$1}-#{$2}"
		end
	}
	f.close
end

def deleteall(delthem)
	if FileTest.directory?(delthem) then
		Dir.foreach( delthem ) do |file|
			next if /^\.+$/ =~ file
			deleteall( delthem.sub(/\/+$/,"") + "/" + file )
    	end
	else
		if delthem =~ /(.*)\.m$/	
			#puts delthem
			open( delthem )
		elsif delthem =~ /(.*)\.h$/	
			#puts delthem
			open( delthem )
		end
	end
end

def searchLocalizableFile(delthem)
	if FileTest.directory?(delthem) then
		Dir.foreach( delthem ) do |file|
			next if /^\.+$/ =~ file
			searchLocalizableFile( delthem.sub(/\/+$/,"") + "/" + file )
    	end
	else
		if delthem =~/.*\/Resources\/(.*?)\.lproj\/Localizable.strings/
			parseLocalizableString( delthem, $1 )
			keys = $words.keys
			keys.each{|key|
				if( $localize[$1][key] == nil )
					$localize[$1][key] = ""
				end
			}
		end
	end
end

def main
	deleteall( ARGV[0] )
	
#	keys = $words.keys
#	keys.sort.each{|key|
#		puts key
#	}

	searchLocalizableFile( ARGV[0] )
	
	localizeKeys = $localize.keys
	localizeKeys.sort.each{|localizeKey|
		puts "------------------------------#{localizeKey}------------------------------"
		keys = $localize[localizeKey].keys
		keys.sort.each{|key|
			puts "\"#{key}\" = \"#{$localize[localizeKey][key]}\";"
		}
	}
end

main()
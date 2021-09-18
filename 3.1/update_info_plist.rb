#!/usr/bin/ruby

def getRevsionAndDate( path )
	svn_result = `svn info #{path} --xml`
	puts svn_result
	revision = nil
	date = nil

	if /<commit\s*revision=\"(\d*)\">/ =~ svn_result
		puts $1
		revision = $1
	end
	
	#if /^(\d*?)[\D\s\:]/ =~ svn_result
	#	revision = $1
	#end
	return revision
end

puts ARGV[0]
puts ARGV[1]
puts ARGV[2]

flag = true

fp = File::open( ARGV[1], "r" )
file = fp.read
revision = getRevsionAndDate( ARGV[2] )
	result = file.sub(/(<key>CFBundleRevision<\/key>\s*<string>)d*?(<\/string>)/){
	puts "Edited"
	flag = false
	$1 + "#{revision}" + $2
}

if flag
result = file.sub(/(<key>CFBundleVersion<\/key>\s*<string>.*?<\/string>)/){
		"<key>CFBundleRevision<\/key><string>#{revision}<\/string>\r" + $1
	}
end

puts result
fp.close

fp = File::open( ARGV[1], "w" )
fp.write( result )
fp.close

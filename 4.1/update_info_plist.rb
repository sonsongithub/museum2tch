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

def checkIfRevisionIncluded( string )
	if string =~ /(<key>CFBundleRevision<\/key>\s*<string>)\d*?(<\/string>)/
		return true
	end
	return false
end

def main
	puts ARGV[0]
	puts ARGV[1]
	`svn update #{ARGV[1]}`
	isFinished = false

	fp = File::open( ARGV[0], "r" )
	file = fp.read
	fp.close
	revision = getRevsionAndDate( ARGV[1] )
	
	if( checkIfRevisionIncluded( file ) )
		result = file.sub( /(<key>CFBundleRevision<\/key>\s*<string>)\d*?(<\/string>)/ ){
			$1 + "#{revision}" + $2
		}
	else
		result = file.sub( /(<key>CFBundleVersion<\/key>\s*<string>.*?<\/string>)/ ){
			"<key>CFBundleRevision</key>\n\t<string>#{revision}</string>\n\t" + $1
		}
	end

	fp = File::open( ARGV[0], "w" )
	fp.write( result )
	puts result
	fp.close
end

main()
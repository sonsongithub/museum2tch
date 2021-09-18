#!/usr/local/bin/ruby

$revision_template = "Last Changed Rev: "
$date_template = "Last Changed Date: "

$revision_template_jp = "リビジョン: "
$date_template_jp = "最終変更日時: "

def getFilePathes
	targetFiles = Array.new
	list = Dir.glob( "*\.lproj" )
	list.each{ |file|
		targetFiles.push( "./#{file}/Localizable.strings" )
	}
	return targetFiles
end

def getRevsionAndDate
	svn_result = `svn info .`
	revision = nil
	date = nil
	if /^#{$revision_template}(.*)$/ =~ svn_result
		revision = $1
	elsif /^#{$revision_template_jp}(.*)$/ =~ svn_result
		revision = $1
	end
	if /^#{$date_template}(.*) \((.*)\)$/ =~ svn_result
		date = $1
	elsif /^#{$date_template_jp}(.*) \((.*)\)$/ =~ svn_result
		date = $1
	end
	return revision,date
end

targetFiles = getFilePathes

revision, date = getRevsionAndDate
targetFiles.each{ |e|
	f = File::open( e, "r" )
	str = f.read
	str = str.gsub( /\"SvnRevision\" = \".*\";/, "\"SvnRevision\" = \"#{revision}\";" )
	str = str.gsub( /\"SvnUpdateDate\" = \".*\";/, "\"SvnUpdateDate\" = \"#{date}\";" )
	f.close
	f = File::open( e, "w" )
	f.write str
	f.close
}
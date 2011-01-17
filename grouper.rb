#!/usr/bin/env ruby

# needed for moving files
require 'fileutils'

# init
arg0 = (ARGV[0] == "")? "." : ARGV[0]
wd   = Dir.getwd

# go to arg0 from wd unless arg0 is an absolute path
workingDirPath = (arg0[0].chr != "/")? File.expand_path(arg0, wd) : arg0

# store the original stdout, just in case...
orig_stdout = $stdout

# name for the log file
logPath = File.join(wd,
  "grouper.log")
#  Time.now().strftime("grouper.%Y-%m-%d_%H-%M-%S.log"))

# open log file
puts "Outputing log to #{logPath}"
FileUtils.touch(logPath)
$stdout = File.new(logPath, 'w')
puts "Working in directory '#{workingDirPath}'\n\n"





# filter files, except for '.' and '..'
files = Dir.entries(workingDirPath).select {|entry|
  File.file? File.join(workingDirPath, entry) and
    !(entry =='.' || entry == '..' || (entry =~ /\.DS_Store|.+\.swp/) != nil )}

# expand the paths of the files
files.map! {|file| File.join(workingDirPath, file)}
puts files
puts "\n\n"





# initialise a hash with the empty list as its default value
fileGroups = Hash.new()

# make each creation date a key in the hash and add all files created on that
# date to the corresponding list in the hash
files.each {|file|
  puts "grouping file '#{file}'"
  cTimeStr = (File.new file).ctime.strftime("%Y-%m-%d")
  if fileGroups[cTimeStr] == nil
    fileGroups[cTimeStr] = [file]
  else
    fileGroups[cTimeStr].push(file)
  end
}

puts "Creating group folders and moving files...\n\n"

# create a directory (unless it already exists) for each date and move the files
# created on that date to the new directory
fileGroups.each_pair {|date, group|
  puts date + ":\n\n"
  dirPath = File.join(workingDirPath, date)
  # create a directory for the date (if needed)
  if !(File.exists?(dirPath))
    puts "Directory '#{dirPath}' does not exist, creating ..."
    FileUtils.mkdir(dirPath)
    puts "Done!"
  end

  # move the files in the group to the directory
  group.each {|file|
    puts "mv #{file} #{dirPath}"
    FileUtils.mv file, dirPath, :verbose => true
  }
}

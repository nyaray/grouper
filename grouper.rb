#!/usr/bin/env ruby

#        Name: grouper.rb
#      Author: Emilio Nyaray (emilio@nyaray.com)
#     License: See file LICENSE
#
# Description: A simple script that organises files in directories by their
#              creation date.

# needed for moving files
require 'fileutils'


##########
#  Init  #
##########

# files and patterns to ignore
ignoreFiles = [".", "..", ".DS_Store", "grouper.rb", "grouper.log"]
ignorePatterns = [/.+\.swp/]

# get the given argument, if none is given, use the girectory where ruby was
# invoked
target = (ARGV.length == 1)? ARGV[0] : "."

# use target as the working path if it is an absolute path, otherwise expand it
# by appending it to the working directory. it will be minimised by FileUtils
workingDirPath = (target[0].chr == "/")?
  target : File.expand_path(target, Dir.getwd)


###################
#  Set up loging  #
###################

# name for the log file, touch it..
logPath = File.join(workingDirPath, "grouper.log")
FileUtils.touch(logPath)

# redirect stdout and store the original, just in case...
puts "Outputing log to #{logPath}"
orig_stdout = $stdout
$stdout = File.new(logPath, 'w')

# open log file
puts "Working in directory '#{workingDirPath}'\n\n"


##################
#  Filter files  #
##################

# reject files, as stated by ignoreFiles and ignorePatterns
files = Dir.entries(workingDirPath).reject! {|entry|
  # is it not a file?
  # are we supposed to ignore it?
  # does it match any of the forbidden patterns?

  notFile      = !File.file?(File.join(workingDirPath, entry))
  ignoredFile  = ignoreFiles.any?    {|file| entry == file}
  patternMatch = ignorePatterns.any? {|pattern| entry =~ pattern}

  notFile or ignoredFile or patternMatch
}

# expand the paths of the files
files.map! {|file| File.join(workingDirPath, file)}
puts files
puts "\n\n"

########################################
#  Group files by their creation date  #
########################################

# initialise an empty hash
fileGroups = Hash.new()

# make each creation date a key in the hash and add all files created on that
# date to the corresponding list in the hash
files.each {|file|
  f = File.new file
  minTime = [f.ctime, f.atime, f.mtime].min
  minTimeStr = minTime.strftime("%Y-%m-%d")
  puts "grouping file '#{file}' with date #{minTimeStr}"
  if fileGroups[minTimeStr] == nil
    fileGroups[minTimeStr] = [file]
  else
    fileGroups[minTimeStr].push(file)
  end
}

puts "Creating group folders and moving files...\n\n"

# create a directory (unless it already exists) for each date and move the files
# created on that date to the new directory
fileGroups.each_pair {|date, group|
  puts date + ":\n"
  dirPath = File.join(workingDirPath, date)
  # create a directory for the date (if needed)
  if !(File.exists?(dirPath))
    puts "Directory '#{dirPath}' does not exist, creating ..."
    FileUtils.mkdir dirPath#, :noop => true
    puts "Done!"
  end

  # move the files in the group to the directory
  group.each {|file|
    puts "mv #{file} #{dirPath}"
    FileUtils.mv file, dirPath, :verbose => true#, :noop => true
  }
}

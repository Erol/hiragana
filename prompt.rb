#!/usr/bin/env ruby

FATARROW = {
  left: "\u2b80",
  right: "\u2b82"
}

THINARROW = {
  left: "\u2b81",
  right: "\u2b83"
}

width = Integer ARGV.shift
directory = ARGV.shift.dup

def colorize(foreground, background, text)
  text = text * "\n" if text.is_a? Array

  "%F{#{foreground}}%K{#{background}}#{text}%f%k%b"
end

def powerline(*args)
  string = ''
  background = nil

  until args.empty? do
    text, fg, bg, direction = args.shift
    direction ||= :left

    if background == bg
      colors = [:black, background]
      string += colorize(*colors, THINARROW[direction])
    elsif background
      colors = [background, bg]
      colors = colors.reverse if direction == :right
      string += colorize(*colors, FATARROW[direction])
    end

    string += colorize(fg, bg, " #{text} ") unless text.nil? || text.empty?

    background = bg
  end

  string
end

segments = []

home = Regexp.new "^#{ENV['HOME']}"

if home.match directory
  directory.gsub! home, ''
  directory.gsub! /^\//, ''

  segments << ['~', :white, :yellow]
else
  directory.gsub! /^\//, ''

  segments << ['/', :white, :yellow]
end

segments << ['', :black, :black]

paths = directory.split('/')

if paths.size > 4
  paths = paths.slice(0, 2) + ["\u2026"] + paths.slice(-2, 2)
end

paths.each do |path|
  segments << [path, :white, :green]
end

segments << ['', :black, :black] unless segments.last.first.empty?

branch = `git rev-parse --abbrev-ref HEAD`.gsub "\n", ''

unless branch.empty?
  segments << [branch, :black, :yellow]
end

float = segments.size

ENV['GS_NAME'].tap do |gemset|
  if gemset
    segments << [gemset, :black, :blue, :right]
  end
end

ENV['RUBY_VERSION'].tap do |version|
  if version
    segments << [version, :black, :blue, :right]
  end
end

segments << ['', :black, :black, :right] unless segments.last.first.empty?

segments << [ENV['USER'], :black, :yellow, :right]
segments << [`hostname`.gsub("\n", ''), :yellow, :black, :right]

katakana = (0x3041..0x3096).to_a + (0x3099..0x309f).to_a

width = segments.reduce(width - 3) do |n, segment|
  s = String(segment.first).size
  n -= s > 0 ? s + 3 : 1
end

fill = '%B' + (width / 2).times.map { [katakana.sample].pack 'U' }.reduce(:+)
fill = fill + ' ' if width % 2 == 1

segments.insert float, [fill, :black, :black]

print powerline(*segments)

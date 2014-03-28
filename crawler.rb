#!/usr/bin/ruby
require 'rubygems'
require 'anemone'
require 'csv'
require 'optparse'

@sourceDomain 	= "http://www.example.org"
@outputPath		= File.dirname(__FILE__)
@verbose		= false
@filter			= false
@regexp			= ''

OptionParser.new do |opts|
	  opts.banner = "Usage: crawler.rb [options]"

	    opts.on("-v", "--[no-]verbose", "Run verbosely") do |v|
			    @verbose = true
		end

		opts.on("-f", "--filter", "Filter print, mailto, pdf, 404, ?  and flv results. To filter missing line-end slashes use ':%s/\\n.*[^/]$//gc' in vim") do |f|
			    @filter = true
		end

		opts.on("-d", "--domain [PATH]", "Domain to crawl e.g. 'http://www.example.org'") do |d|
			    @sourceDomain = d
		end
		
		opts.on("-o", "--output [PATH]", "Output path e.g. '/Users/JohnDoe/Desktop'") do |o|
			    @outputPath = o
		end

		opts.on("-l", "--limit [REGEXP]", "Limit to sub path e.g. 'en\\/news\\/'") do |l|
			    @regexp = l
		end
end.parse!

@crawled		= Array.new
@outputPostfix  = (@regexp != '') ? '-' + @regexp.split('\/').join('+') : ''
@outputFile		= @sourceDomain.split('/')[-1].split('.').join("_") + @outputPostfix + ".csv"
@options		= {
	:accept_cookies => true,
	:read_timeout => 20,
	:retry_limit => 0,
	:verbose => false,
	:discard_page_bodies => true,
	:user_agent => 'Lingewoud 550 Spyder'
}

Anemone.crawl(@sourceDomain, @options ) do |anemone|

	anemone.on_pages_like(/#{@regexp}[^?]*$/) do |page|
		url = page.url.to_s	
		
		# we probably should use anemone.skip_links_like /\/account\// for filtering 
		if(!@filter || !( url.index('print') || url.index('mailto') || url.index('.pdf') || url.index('.flv') || url.index('404') || url.index('?')) )
			puts url if @verbose 
			@crawled << url
		end
	end
end

puts "\nwriting data to: " +@outputPath + '/' + @outputFile if @verbose

CSV.open( @outputPath + '/' + @outputFile, "wb") do |row|
	row << ["url"]

	(0..@crawled.length - 1).each do |index|
		row << [ @crawled[index] ]
	end
end

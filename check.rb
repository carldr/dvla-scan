require "rubygems"
require "excon"

def no_equiv( word, converted )
	puts "No equivalent for #{word.downcase}/#{converted}"
end

while gets
	word = $_.strip.upcase

	if word =~ /^(.)(.)(..)(.)(.)(.)$/
		prefix1, prefix2, numbers, letter1, letter2, letter3 = $1, $2, $3, $4, $5, $6
	end

	{ :a => 4,
	  :b => 8,
	  :d => 0,
	  :e => 3,
	  :g => 6,
	  :h => 4,
	  :i => 1,
	  :l => 1,
	  :o => 0,
	  :s => 5,
	  :t => 7,
	  :y => 7,
	  :z => 2 }.each do |k, v|
		numbers.gsub!( /#{k}/i, v.to_s )
	end

	converted = "#{prefix1}#{prefix2}#{numbers}#{letter1}#{letter2}#{letter3}"

	if numbers =~ /[A-Z]+/ or converted =~ /I/ or converted =~ /Q/
		no_equiv( word, converted )
		next
	end

	number = numbers.to_i
	
	if ( number < 2 or number > 14 ) and ( number < 51 or number > 63 )
		no_equiv( word, converted )
		next
	end
	
	params = { :prefix1 => prefix1,
	           :prefix2 => prefix2,
	           :numbers => numbers,
	           :letter1 => letter1,
	           :letter2 => letter2,
	           :letter3 => letter3,
	           :action => "current",
	           :pricefrom => "0",
	           :priceto => "",
	           :currentmatches => "8",
	           :searched => "true",
	           :openoption => "yes",
	           :language => "en",
	           :"prefix2.x" => "33",
	           :"prefix2.y" => "32" }
	           
	headers = { "User-Agent" => "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9) AppleWebKit/537.71 (KHTML, like Gecko) Version/7.0 Safari/537.71",
	            "Referer" => "http://dvlaregistrations.direct.gov.uk/search/current-number-plates.html?prefix1=S&prefix2=C&numbers=06&letter1=G&letter2=A&letter3=&action=current&pricefrom=0&priceto=&currentmatches=16&searched=true&openoption=yes&language=en&prefix2.x=34&prefix2.y=35" }

	success_file = "#{converted}.txt"
	fail_file = "#{converted}-302.txt"

	if File.exists?( fail_file )
		puts "#{word.downcase}/#{converted}  Status 302 (Cached)"
		next
	end

	if not File.exists?( success_file )
		conn = Excon.new( "http://dvlaregistrations.direct.gov.uk/search/current-number-plates.html" )
		response = conn.get( :query => params, :headers => headers )
		sleep 1

		File.open( response.status == 200 ? success_file : fail_file, "w" ) do |f|
			f.write response.body
		end

		if response.status != 200
			puts "#{word.downcase}/#{converted}  Status #{response.status}"
			next
		end
	end

	body = File.read( success_file )

	matches = body.scan( /addWishlist\('(.*?)', '(\d+)'\)/ )
	if matches.size == 0
		puts "No matches for #{word.downcase}/#{converted}"
		next
	end
	
	matches.each do |reg, price|
		puts "#{word.downcase}   Found #{reg}   £#{price}"
	end
end
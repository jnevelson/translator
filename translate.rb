require 'yaml'
require 'google_translate'

def translate_hash(hash)
  {}.tap do |hsh|
    hash.each do |key, val|
      case val
      when Hash
        hsh[key] = translate_hash(val)
      when Array
        hsh[key] = val.map { |v| translate(v) }
      else
        begin
          tr = translate(val)
          hsh[key] = tr
          puts "#{@counter+=1}. #{val} -- #{tr}"
        rescue Exception => e
          # Super weird bug with certain words in zh_cn locale...
          # https://github.com/shvets/google-translate/issues/6
          if exceptions[val.downcase]
            hsh[key] = exceptions[val]
            puts "#{@counter+=1}. #{val}"
          else
            raise "#{e} -- key: #{key} -- val: #{val}"
          end
        end
      end
    end
  end
end

def translate(word)
  @translator.translate(:en, @locale, word)[0].encode("utf-8")
end

def exceptions
  {
    "slow" => "\xE7\xBC\x93\xE6\x85\xA2",
    "fast" => "\xE5\xBF\xAB",
    "high" => "\xE9\xAB\x98",
    "crouch" => "\xE8\xB9\xB2\xE4\xBC\x8F",
    "speed" => "\xE9\x80\x9F\xE5\xBA\xA6",
    "short" => "\xE7\x9F\xAD",
    "long" => "\xE9\x95\xBF",
    "quick" => "\xE5\xBF\xAB\xE9\x80\x9F",
    "head" => "\xE5\xA4\xB4",
    "down" => "\xE4\xB8\x8B\xE9\x99\x8D"
  }
end

@locale = ARGV[0]
@counter = 0
@translator = Google::Translator.new
yml = YAML.load(File.open(ARGV[1]))
translated_hash = {}.tap { |h| h[@locale] = translate_hash(yml["en"]) }
File.open("#{@locale}.yml", "w") { |f| f.write(translated_hash.to_yaml) }

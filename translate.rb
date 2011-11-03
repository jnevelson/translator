require 'yaml'
require 'google_translate'

def translate_hash(hash)
  {}.tap do |hsh|
    hash.each do |k, v|
      case v
      when Hash
        hsh[k] = translate_hash(v)
      when Array
        hsh[k] = v.map { |a| translate(a) }
      else
        begin
          tr = translate(v)
          puts "#{@counter+=1}. #{v} -- #{tr}"
          hsh[k] = tr
        rescue Exception => e
          return hsh
        end
      end
    end
  end
end

def translate(word)
  @translator.translate(:en, @locale, word)[0].force_encoding('utf-8')
end

@locale = ARGV[0]
@counter = 0
@translator = Google::Translator.new
yml = YAML.load(File.open(ARGV[1]))
translated_hash = {}.tap { |h| h[@locale] = translate_hash(yml["en"]) }
File.open("#{@locale}.yml", "w") { |f| f.write(translated_hash.to_yaml) }

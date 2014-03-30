class BlockProfiler
  if %w(development test).include?(Rails.env)
    def self.measure(file_name='prof')
      RubyProf.start
      yield
      results = RubyProf.stop
      
      FileUtils.mkdir_p "#{Rails.root}/tmp/performance"
      # Print a flat profile to text
      File.open "#{Rails.root}/tmp/performance/#{file_name}-graph.html", 'w' do |file|
        RubyProf::GraphHtmlPrinter.new(results).print(file)
      end
   
      File.open "#{Rails.root}/tmp/performance/#{file_name}-flat.txt", 'w' do |file|
        # RubyProf::FlatPrinter.new(results).print(file)
        RubyProf::FlatPrinterWithLineNumbers.new(results).print(file)
      end
   
      File.open "#{Rails.root}/tmp/performance/#{file_name}-stack.html", 'w' do |file|
        RubyProf::CallStackPrinter.new(results).print(file)
      end
    end
  else
    def self.measure(file_name='prof')
    end
  end
end
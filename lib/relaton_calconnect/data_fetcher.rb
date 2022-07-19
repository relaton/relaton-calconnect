# frozen_string_literal:true

module RelatonCalconnect
  #
  # Relaton-calconnect data fetcher
  #
  class DataFetcher
    # DOMAIN = "https://standards.calconnect.org/"
    # SCHEME, HOST = DOMAIN.split(%r{:?/?/})
    ENDPOINT = "https://standards.calconnect.org/relaton/index.yaml"
    # DATADIR = "data"
    # DATAFILE = File.join DATADIR, "bibliography.yml"
    # ETAGFILE = File.join DATADIR, "etag.txt"

    def initialize(output, format)
      @output = output
      @etagfile = File.join output, "etag.txt"
      @format = format
    end

    def self.fetch(output: "data", format: "yaml")
      t1 = Time.now
      puts "Started at: #{t1}"
      FileUtils.mkdir_p output
      new(output, format).fetch
      t2 = Time.now
      puts "Stopped at: #{t2}"
      puts "Done in: #{(t2 - t1).round} sec."
    end

    #
    # fetch data form server and save it to file.
    #
    def fetch
      resp = Faraday.new(ENDPOINT, headers: { "If-None-Match" => etag }).get
      # return if there aren't any changes since last fetching
      return unless resp.status == 200

      data = YAML.safe_load resp.body
      all_success = true
      data["root"]["items"].each do |doc|
        success = parse_page doc
        all_success &&= success
      end
      self.etag = resp[:etag] if all_success
    end

    private

    #
    # Parse document and write it to file
    #
    # @param [Hash] doc
    #
    def parse_page(doc)
      bib = Scrapper.parse_page doc
      # bib.link.each { |l| l.content.merge!(scheme: SCHEME, host: HOST) unless l.content.host }
      write_doc doc["docid"]["id"], bib
      true
    rescue StandardError => e
      warn "Document: #{doc['docid']['id']}"
      warn e.message
      warn e.backtrace[0..5].join("\n")
      false
    end

    def write_doc(docid, bib)
      content = @format == "xml" ? bib.to_xml(bibdata: true) : bib.to_hash.to_yaml
      file = File.join @output, "#{docid.upcase.gsub(%r{[/\s:]}, '_')}.#{@format}"
      # if File.exist? file
      #   warn "#{file} exist"
      # else
      File.write file, content, encoding: "UTF-8"
      # end
    end

    #
    # Read ETag from file
    #
    # @return [String, NilClass]
    def etag
      @etag ||= File.exist?(@etagfile) ? File.read(@etagfile, encoding: "UTF-8") : nil
    end

    #
    # Save ETag to file
    #
    # @param tag [String]
    def etag=(e_tag)
      File.write @etagfile, e_tag, encoding: "UTF-8"
    end
  end
end

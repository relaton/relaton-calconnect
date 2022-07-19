module RelatonCalconnect
  class HashConverter < RelatonBib::HashConverter
    class << self
      # @param ret [Hash]
      def editorialgroup_hash_to_bib(ret)
        return unless ret[:editorialgroup]

        technical_committee = RelatonBib.array(ret[:editorialgroup]).map do |wg|
          TechnicalCommittee.new RelatonBib::WorkGroup.new(**wg)
        end
        ret[:editorialgroup] = RelatonBib::EditorialGroup.new technical_committee
      end
    end
  end
end

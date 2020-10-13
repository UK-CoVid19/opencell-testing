# frozen_string_literal: true
require 'ostruct'
class Client < ApplicationRecord
  has_many :samples, dependent: :destroy

  validates :name, uniqueness: true
  before_create :hash_api_key

  attr_accessor :api_key

  def self.control_client
    c = find_by(name: CONTROL_NAME)
    c = Client.create!(name: CONTROL_NAME, api_key: SecureRandom.base64(16), notify: false) if c.nil?
    c
  end

  CONTROL_NAME = "control"
  INTERNAL_RERUN_NAME = 'Posthoc Retest'

  def hash_api_key
    raise "API key required" if api_key.blank?

    self.api_key_hash = Digest::SHA256.base64digest(api_key.encode('UTF-8'))
  end

  def stats
    received = Sample.states[:received]
    commcomplete = Sample.states[:commcomplete]
    retest = Sample.states[:retest]
    reject = Sample.states[:rejected]

    query = <<-SQL
        select
        foo.date,
        count(case when foo.states @> ARRAY[#{received}] and foo.notes @> array['Created from API']::varchar[] then 1 else null end) as requested,
        count(case when foo.states @> ARRAY[#{commcomplete}] and not foo.states @> ARRAY[#{reject}] then 1 else null end) as communicated,
        count(case when foo.states @> ARRAY[#{reject}] then 1 else null end) as rejects,
        count(case when foo.states @> ARRAY[#{retest}] and not foo.states @> ARRAY[#{[reject]}] and not foo.states @> ARRAY[#{[commcomplete]}] then 1 else null end) as retests,
        count(case when foo.states @> ARRAY[#{retest}] and not foo.states @> ARRAY[#{reject}] and foo.states @> ARRAY[#{[commcomplete, retest].join(',')}] then 1 else null end) as internalchecks
        from (
          select date(r.updated_at) as date, r.sample_id as sample_id, array_agg(r.state) as states, array_agg(r.note) as notes
          from public.records r
          inner join public.samples s on sample_id = s.id
          where s.client_id = #{self.id}
          and r.state in(#{[received, commcomplete, retest, reject].join(',')})
          and s.control = false
          group by date(r.updated_at), r.sample_id ) as foo
        group by foo.date
        order by foo.date desc
    SQL

    results = ActiveRecord::Base.connection.execute(query)
    results.map { |r| OpenStruct.new(r) }.map { |i| Stat.new(i) }
  end
end

class Stat
  attr_reader :requested, :communicated, :retests, :rejects, :date, :internalchecks
  def initialize(args)
    @requested = args.requested
    @communicated = args.communicated
    @retests = args.retests
    @rejects = args.rejects
    @internalchecks = args.internalchecks
    @date = args.date
  end
end

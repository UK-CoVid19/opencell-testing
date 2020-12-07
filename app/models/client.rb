# frozen_string_literal: true
require 'ostruct'
class Client < ApplicationRecord
  include ClientNotifyModule
  has_many :samples, dependent: :destroy
  has_many :headers, dependent: :destroy
  accepts_nested_attributes_for :headers, allow_destroy: true
  validates :url, presence: true, if: :notify?
  validates :url, format: URI::regexp(%w[https]), if: :notify?

  validates_uniqueness_of :name, scope: [ :labgroup ]
  before_create :hash_api_key
  belongs_to :labgroup

  attr_accessor :api_key

  def self.control_client(labgroup)
    find_or_create_by!(name: CONTROL_NAME, labgroup: labgroup) do |c|
      c.api_key = SecureRandom.base64(16)
      c.notify = false
    end
  end

  CONTROL_NAME = 'control'
  INTERNAL_RERUN_NAME = 'Posthoc Retest'

  scope :real, -> { where.not(name: [CONTROL_NAME, INTERNAL_RERUN_NAME]) }

  def hash_api_key
    raise "API key required" if api_key.blank?

    self.api_key_hash = Digest::SHA256.base64digest(api_key.encode('UTF-8'))
  end

  def test_webhook
    raise "Client cannot notify" unless notify?

    to_send = {
      'sampleid' => "TEST",
      'result' => ClientNotifyModule::INCONCLUSIVE
    }
    response = make_request(to_send, self)
    if [200, 202].include? response.code.to_i
      return true
    else
      return false
    end
  end

  def stats
    query = <<-SQL
      select teststats.date, teststats.requested, teststats.communicated, teststats.retests, teststats.rejects, teststats.internalchecks, stat.positives, stat.negatives, stat.inconclusives, stat.percent_positive, stat.total_tests, turnaround.avg, turnaround.min, turnaround.max from

      (select 
      dates.date,
      count(case when foo.states @> ARRAY[2] and foo.notes @> array['Created from API']::varchar[] then 1 else null end) as requested,
      count(case when foo.states @> ARRAY[8] and not foo.states @> ARRAY[10] then 1 else null end) as communicated,
      count(case when foo.states @> ARRAY[11] and not foo.states @> ARRAY[10] and not foo.states @> ARRAY[8] then 1 else null end) as retests,
      count(case when foo.states @> ARRAY[10] then 1 else null end) as rejects,
      count(case when foo.states @> ARRAY[11] and not foo.states @> ARRAY[10] and foo.states @> ARRAY[8,11] then 1 else null end) as internalchecks
      
      from
      
      (SELECT t.day::date as date
      FROM   generate_series(timestamp '2020-09-11', now(), interval  '1 day') AS t(day)) as dates
      
      left join
      (select date(r.updated_at) as updated_at, array_agg(r.state) as states, array_agg(r.note) as notes from samples s
      inner join records r on r.sample_id = s.id
      where s.client_id = #{id}
      and s.uid not like '%-r'
      and r.state in(2,8,11,10)
      group by date(r.updated_at), r.sample_id
      ) as foo
      
      on dates.date = date(foo.updated_at)
      group by dates.date
      order by dates.date desc) as teststats
      
      
      join
      
      (select
      COUNT(case when smp.state in(0,1) then 1 else null end ) as positives,
      COUNT(case when smp.state = 2 then 1 else null end ) as negatives,
      COUNT(case when smp.state = 3 then 1 else null end ) as inconclusives,
      ROUND(100.0 * (COUNT(case when smp.state in(0,1) then 1 else null end )::numeric / greatest(COUNT(smp.id),1)), 1) as percent_positive,
      COUNT(case when smp.state in(0,1,2,3) then 1 else null end) as total_tests,
      res_dates.date
      
      from 
      (SELECT t.day::date as date
      FROM generate_series(timestamp '2020-09-11', now(), interval  '1 day') AS t(day)) as res_dates
      
      left join 
      (select r.updated_at, tr.state, tr.id from samples s
      inner join wells w on s.id = w.sample_id
      inner join test_results tr on tr.well_id = w.id
      inner join records r on r.sample_id = s.id
      where s.control = false
      and s.uid not like '%-r'
      and s.client_id = #{id}
      and r.state = 8
      ) as smp
      
      on res_dates.date = date(smp.updated_at)
      group by res_dates.date
      order by res_dates.date desc) stat
      on teststats.date = stat.date

      join
      
      (
      select dates.date,  date_trunc('second', avg(completed.finished_at - completed.created_at)) as avg, date_trunc('second', min(completed.finished_at - completed.created_at)) as min, date_trunc('second', max(completed.finished_at - completed.created_at)) as max
      from (
      
        (SELECT t.day::date as date
              FROM   generate_series(timestamp '2020-09-11', now(), interval  '1 day') AS t(day)) as dates
        
        left join
      
        (select s.id, s.state, date(s.created_at) as date, s.created_at as created_at, case when rS.is_retest = true then rS.updated_at else s.updated_at end as finished_at, rS.is_retest 
        from samples s
        left outer join reruns r2 on r2.sample_id = s.id
        left outer join samples rS on rS.id = r2.retest_id
        where s.state in(8,11)
        and s.client_id = #{id}
        and rS.state isnull or rS.state = 8
        and s."control" = false) as completed
        on dates.date = completed.date
        )
        group by dates.date
      ) turnaround
      on teststats.date = turnaround.date
    SQL

    results = ActiveRecord::Base.connection.execute(query)
    results.map { |r| OpenStruct.new(r) }.map { |i| Stat.new(i) }
  end
end


class Stat
  attr_reader :requested, :communicated, :retests, :rejects, :date, :internalchecks, :positives, :negatives, :inconclusives, :percent_positive, :total_tests, :avg, :min, :max
  def initialize(args)
    @requested = args.requested
    @communicated = args.communicated
    @retests = args.retests
    @rejects = args.rejects
    @internalchecks = args.internalchecks
    @date = args.date
    @positives = args.positives
    @negatives = args.negatives
    @inconclusives = args.inconclusives
    @percent_positive = args.percent_positive
    @total_tests = args.total_tests
    @avg = args.avg
    @min = args.min
    @max = args.max
  end
end

# Copyright 2015 Google Inc. All rights reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a extract of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

require "helper"

describe Gcloud::Bigquery::Project, :query_job, :mock_bigquery do
  let(:query) { "SELECT name, age, score, active FROM [some_project:some_dataset.users]" }
  let(:dataset_id) { "my_dataset" }
  let(:dataset_gapi) { random_dataset_gapi dataset_id }
  let(:dataset) { Gcloud::Bigquery::Dataset.from_gapi dataset_gapi,
                                                      bigquery.service }
  let(:table_id) { "my_table" }
  let(:table_gapi) { random_table_gapi dataset_id, table_id }
  let(:table) { Gcloud::Bigquery::Table.from_gapi table_gapi,
                                                  bigquery.service }

  it "queries the data" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi(query)
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query
    mock.verify

    job.must_be_kind_of Gcloud::Bigquery::QueryJob
  end

  it "queries the data with options set" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi(query)
    job_gapi.configuration.query.priority = "BATCH"
    job_gapi.configuration.query.use_query_cache = false
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query, priority: :batch, cache: false
    mock.verify

    job.must_be_kind_of Gcloud::Bigquery::QueryJob
  end

  it "queries the data with table options" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi(query)
    job_gapi.configuration.query.destination_table = Google::Apis::BigqueryV2::TableReference.new(
      project_id: table.project_id,
      dataset_id: table.dataset_id,
      table_id:   table.table_id
    )
    job_gapi.configuration.query.create_disposition = "CREATE_NEVER"
    job_gapi.configuration.query.write_disposition = "WRITE_TRUNCATE"
    job_gapi.configuration.query.allow_large_results = true
    job_gapi.configuration.query.flatten_results = false
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query, table: table,
                                create: :never, write: :truncate,
                                large_results: true, flatten: false
    mock.verify

    job.must_be_kind_of Gcloud::Bigquery::QueryJob
  end

  it "queries the data with dataset option as a Dataset" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi(query)
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: dataset.project_id,
      dataset_id: dataset.dataset_id
    )
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query, dataset: dataset
    mock.verify

    job.must_be_kind_of Gcloud::Bigquery::QueryJob
  end

  it "queries the data with dataset option as a String" do
    mock = Minitest::Mock.new
    bigquery.service.mocked_service = mock

    job_gapi = query_job_gapi(query)
    job_gapi.configuration.query.default_dataset = Google::Apis::BigqueryV2::DatasetReference.new(
      project_id: dataset.project_id,
      dataset_id: dataset.dataset_id
    )
    mock.expect :insert_job, job_gapi, [project, job_gapi]

    job = bigquery.query_job query, dataset: dataset_id
    mock.verify

    job.must_be_kind_of Gcloud::Bigquery::QueryJob
  end
end

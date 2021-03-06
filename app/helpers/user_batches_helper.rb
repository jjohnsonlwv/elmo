module UserBatchesHelper
  def get_line_errors(line)
    errors = []
    errors += line[:user].errors.full_messages if line[:user]
    errors << t("user_batch.bad_tokens", tokens: line[:bad_tokens].join(", ")) unless line[:bad_tokens].empty?
    truncate(errors.join(", "), length: 100)
  end

  def formatted_instructions
    xlsx_url = example_spreadsheet_user_batches_path(format: "xlsx")
    csv_url = example_spreadsheet_user_batches_path(format: "csv")
    simple_format(t("user_batch.instructions_html", xlsx_url: xlsx_url, csv_url: csv_url), {}, sanitize: false)
  end
end

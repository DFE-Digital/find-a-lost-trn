class DqtRecordComponent < ViewComponent::Base
  def initialize(dqt_record:)
    super
    @dqt_record = dqt_record
  end

  def full_name
    @dqt_record.fetch("name", nil)
  end

  def date_of_birth
    @dqt_record.fetch("dob", nil)&.to_date&.to_fs(:long_ordinal_uk)
  end

  def nino
    @dqt_record.fetch("ni_number", nil) ? "Given" : "Not Given"
  end

  def trn
    @dqt_record["trn"]
  end
end

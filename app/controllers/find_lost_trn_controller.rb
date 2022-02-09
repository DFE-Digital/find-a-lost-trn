# frozen_string_literal: true
class FindLostTrnController < ApplicationController
  include Wizardry

  wizard(
    name: :find_lost_trn,
    class_name: 'Teacher',
    edit_path_helper: :teacher_edit_path,
    update_path_helper: :teacher_update_path,
    pages: [
      Wizardry::Pages::QuestionPage.new(
        :check_trn,
        title: 'Check if you have a TRN',
        questions: [Wizardry::Questions::Radios.new(:do_you_have_a_trn, '1' => 'Yes', '0' => 'No')],
      ),
      Wizardry::Pages::QuestionPage.new(
        :ask_questions,
        title: 'We’ll ask you some questions to help find your TRN',
        questions: [],
      ),
    ],
  )
end

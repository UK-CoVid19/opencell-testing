class CreateSecurityQuestions < ActiveRecord::Migration[6.0]
  def change
    create_table :security_questions do |t|
      t.string :locale, null: false
      t.string :name, null: false
    end

    add_reference :users, :security_question, foreign_key: true
    add_column :users, :security_question_answer, :string

    SecurityQuestion.create! locale: :en, name: 'What is your mothers maiden name?'
    question = SecurityQuestion.create! locale: :en, name: 'Where were you born?'
    SecurityQuestion.create! locale: :en, name: 'What did you name your first pet?'
    SecurityQuestion.create! locale: :en, name: 'What is your favourite film?'
    SecurityQuestion.create! locale: :en, name: 'What is your favourite book?'
    SecurityQuestion.create! locale: :en, name: 'What is your favourite animal?'
    SecurityQuestion.create! locale: :en, name: 'What is your favourite country to visit?'


    User.update_all(security_question_id: question.id, security_question_answer: 'London')

  end


end

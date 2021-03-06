class Category < ActiveRecord::Base
  # CONSTANTS
  EQUAL_TO               = 0
  LESS_THAN              = 1
  LESS_THAN_OR_EQUAL     = 2
  GREATER_THAN           = 3
  GREATER_THAN_OR_EQUAL  = 4
  NOT_EQUAL              = 5
  
  STRING                 = 0
  INTEGER                = 1
  FLOAT                  = 2
  DATE                   = 3
  NIL                    = 4
  
  # ASSOCIATIONS
  belongs_to   :company
  has_many     :subcategories,     -> { order(:priority) }, class_name: "Category",  foreign_key: "parent_id"
  belongs_to   :parent,            class_name: "Category"
  has_one      :rule_set,          foreign_key: 'code', class_name: 'RuleSet', primary_key: 'code'
  
  # VALIDATION
  validates    :tab_name, :datatype, :operation, :company_id, presence: true
  validates    :operation, inclusion: { in: [EQUAL_TO, LESS_THAN, LESS_THAN_OR_EQUAL, GREATER_THAN, GREATER_THAN_OR_EQUAL, NOT_EQUAL ] }
  validates    :datatype, inclusion: { in: [STRING, INTEGER, FLOAT, DATE, NIL ] } 
  validate     :matchesParentCompany?, :valueIsPresent?
  
  # SCOPES
  scope        :root_categories,  -> { where( parent_id: nil ).order(:company_id, :priority) }
  
  # DATA ACCESS METHODS
  
  # UTILITY METHODS
  def to_s
    "#{tab_name} #{operation_string} #{tab_value}"
  end
  
  def combined_strings
    combination = []
    
    subcategories.each do |subcategory|
      inner_comb = subcategory.combined_strings
      inner_comb.each do |comb|
        combination.push( [ "#{self.to_s} & #{comb[0]}", comb[1] ] )
      end
    end
    
    unless code.blank?
      combination.push( [ self.to_s, rule_set.to_s ] )
    end
    
    return combination
  end

  def combined_super
    
    if parent.nil?
      ""
    elsif parent.parent.nil?
      parent.to_s
    else
      "#{parent.combined_super} & #{parent.to_s}"
    end
    
  end

  def operation_string
    case operation
      when EQUAL_TO
        "="
      when LESS_THAN
        "<"
      when LESS_THAN_OR_EQUAL
        "<="
      when GREATER_THAN
        ">"
      when GREATER_THAN_OR_EQUAL
        ">="
      when NOT_EQUAL
        "<>"
      else
      "Unknown operation"
    end
  end
  
  def datatype_string
    case datatype
      when STRING
        "STRING"
      when INTEGER
        "INTEGER"
      when FLOAT
        "FLOAT"
      when DATE
        "DATE"
      when NIL
        "NIL"
      else
        "Unknown Datatype"
    end
  end

  def valueIsPresent?
    if datatype != NIL && tab_value.blank?
      errors.add(:tab_value, "Must be present unless datatype is 'NIL'") 
    end
  end

  def matchesParentCompany?
    unless parent.nil? || parent.company_id == company_id 
      errors.add(:company, "Must match parent Company") 
    end
  end

  #########################################################################
  # Making Constants "Public"
  #########################################################################

  
  def self.EQUAL_TO
    EQUAL_TO
  end
  
  def self.LESS_THAN
    LESS_THAN
  end
  
  def self.LESS_THAN_OR_EQUAL
    LESS_THAN_OR_EQUAL
  end
  
  def self.GREATER_THAN
    GREATER_THAN
  end
  
  def self.GREATER_THAN_OR_EQUAL
    GREATER_THAN_OR_EQUAL
  end
  
  def self.NOT_EQUAL
    NOT_EQUAL
  end
  
  def self.STRING
    STRING
  end
  
  def self.INTEGER
    INTEGER
  end
  
  def self.FLOAT
    FLOAT
  end
  
  def self.DATE
    DATE
  end
  
  def self.NIL
    NIL
  end
end

  
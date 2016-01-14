require 'securerandom'
# TODO devolver cantidad como instancias de Money
class Dinero < ActiveRecord::Base
  timestamps
  validates_format_of :responsable,
                      with: /(IKER|CAMILA|MAIA|LEA|BERNAT|MARTA|GALA|SARA|MARC|JOSEPHINE)/,
                      on: :create

  property :cantidad, as: :integer
  property :moneda, as: :string, default: 'HS'
  property :responsable, index: true
  property :comentario, as: :text
  property :codigo, as: :string

  before_create :asignar_codigo!

  def nombre
    responsable.split('@').first
  end

  def dinero
    Money.new(cantidad, moneda)
  end

  def moneda=(tipo)
    write_attribute(:moneda, tipo.upcase)
  end

  def responsable=(tipo)
    write_attribute(:responsable, tipo.upcase)
  end

  private

  def asignar_codigo!
    self.codigo = SecureRandom.uuid unless codigo
  end
end

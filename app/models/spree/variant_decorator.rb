Spree::Variant.class_eval do

  ## Associations

  has_one :default_price,
    -> { where currency: Spree::Config[:currency], price_book_id: Spree::PriceBook.default.id },
    class_name: 'Spree::Price',
    dependent: :destroy

  has_many :price_books, -> { active.order('spree_prices.amount ASC, spree_price_books.priority DESC') }, through: :prices

  has_many :prices,
    class_name: 'Spree::Price',
    dependent: :destroy,
    inverse_of: :variant

  ## Class Methods

  ## Instance Methods

  def display_list_price(currency = Spree::Config[:currency], store = Spree::Store.default, roles = nil)
    lp = list_price_in(currency, store)
    raise RuntimeError, "No available price for Variant #{id} with #{currency} currency in the #{store.code} store." unless lp
    Spree::Money.new lp.amount, currency: lp.currency
  end

  def list_price_in(currency = Spree::Config[:currency], store = Spree::Store.default, roles = nil)
    if store.try :persisted?
      prices.list.by_currency(currency).by_store(store.id).by_role(roles).first
    else
      prices.list.by_currency(currency).by_role(roles).first
    end
  end

  def price_in(currency = Spree::Config[:currency], store = Spree::Store.default, roles = nil)
    if store.try :persisted?
      prices.by_currency(currency).by_store(store.id).by_role(roles).first
    else
      prices.by_currency(currency).by_role(roles).first
    end
  end

end
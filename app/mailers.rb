Dineros::App.mailer :dineros do
  email :movimiento do |dinero, url|
    to dinero.responsable
    subject 'Notificación de dineros'
    locals dinero: dinero, url_para_desconfirmar: url
    provides :html
    render 'dineros/movimiento'
    gpg sign: true, password: ENV['GPG_PASSWORD']
  end

  email :borrado do |dinero|
    to ENV['EMAIL_ADMIN']
    subject 'Movimiento eliminado'
    locals dinero: dinero
    provides :html
    render 'dineros/borrado'
    gpg sign: true, password: ENV['GPG_PASSWORD']
  end
end

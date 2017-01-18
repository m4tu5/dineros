require 'time'
Dineros::App.controllers :dinero do

  get :index do
    redirect '/'
  end

  post :ingresar do
    cantidad = (params[:dinero][:cantidad].to_f * 100).to_i
    @dinero = Dinero.new(params[:dinero])
# TODO esto podría ir en la validación del modelo...
    # numero de 2 decimales, se eliminan los decimales sobrantes
    @dinero.cantidad = cantidad
    @dinero.moneda = params[:dinero][:moneda]

    if cantidad > 0
      if @dinero.save
        deliver :dineros, :movimiento, @dinero, url_para_desconfirmar(@dinero)

        redirect '/'
      else
        'Hubo un error al grabar los datos'
      end
    else
      'La cantidad debe ser un número positivo'
    end
  end

  get :desconfirmar, with: :id do
    @dinero = Dinero.find_by(codigo: params[:id])

    render 'dinero/desconfirmar'
  end

  post :desconfirmar do
    if params[:dinero][:codigo]
      @dinero = Dinero.find_by(codigo: params[:dinero][:codigo])
    # TODO arreglar el envio de un mensaje cuando se borra un movimiento
    # cuando este funcione bien, enviar links de borrado a usuarios
    # deliver :dineros, :borrado, @dinero
      @dinero.destroy!
    end

    redirect '/'
  end

  post :desembolsar  do
    cantidad = (params[:dinero][:cantidad].to_f * 100).to_i
    @dinero = Dinero.new(params[:dinero])
# TODO esto podría ir en la validación del modelo...
    # numero de 2 decimales, se eliminan los decimales sobrantes
    # no se redondea
    @dinero.cantidad = cantidad * -1
    @dinero.moneda = params[:dinero][:moneda]

    if cantidad > 0
      if @dinero.save
        deliver :dineros, :movimiento, @dinero, url_para_desconfirmar(@dinero)

        redirect '/'
      else
        'Hubo un error'
      end
    else
      'La cantidad debe ser un número positivo'
    end
  end

  post :transferir  do
    unless params[:dinero][:cantidad].to_f > 0
      return '<h1>La cantidad debe ser un número positivo</br>Regrese al formulario y corrija el error</h1>'.html_safe
    end
    if params[:dinero][:responsable_entrega] == 'Seleccione pescadora que'
      return '<h1>Seleccione quien Entrega el tiempo</br>Regrese al formulario y corrija el error</h1>'.html_safe
    end
    if params[:dinero][:responsable_recibe] == 'Seleccione pescadora que'
      return '<h1>Seleccione quien Recibe el tiempo</br>Regrese al formulario y corrija el error</h1>'.html_safe
    end

    # numero de 2 decimales, se eliminan los decimales sobrantes
    # no se redondea
    cantidad = (params[:dinero][:cantidad].to_f * 100).to_i
    # fija la moneda en HS, para el banco de tiempo
    #moneda = params[:dinero][:moneda]
    moneda = 'HS'

    if params[:dinero][:responsable_recibe] == "Todas (suplencia)"
      receptores = Array['Bernat','Gala','Greta','Iker','Lea','Maia','Marc','Marta','Oli','Sara']
      cantidad = cantidad / 10
    else
      receptores = Array[params[:dinero][:responsable_recibe]]
    end

    receptores.each do |r|
      @dinero_entrega = Dinero.new
      @dinero_entrega.cantidad = cantidad
      @dinero_entrega.moneda = moneda
      @dinero_entrega.responsable = params[:dinero][:responsable_entrega]
      @dinero_entrega.comentario = ''.concat(params[:dinero][:responsable_entrega]).concat(' →  ').concat(params[:dinero][:responsable_recibe]).concat(': ').concat(params[:dinero][:comentario])

      @dinero_recibe = Dinero.new
      @dinero_recibe.cantidad = cantidad * -1
      @dinero_recibe.moneda = moneda
      @dinero_recibe.responsable = r
      @dinero_recibe.comentario = @dinero_entrega.comentario
      @dinero_entrega.save
      @dinero_recibe.save

      deliver :dineros, :movimiento, @dinero_entrega, url_para_desconfirmar(@dinero_entrega)
      deliver :dineros, :movimiento, @dinero_recibe, url_para_desconfirmar(@dinero_recibe)
    end
    redirect '/'
  end
end

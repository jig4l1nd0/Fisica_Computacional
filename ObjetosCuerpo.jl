#Objetos para la animación de la caminata
include("MisObjetos.jl")
using LinearAlgebra

abstract type PartesDelCuerpo end

mutable struct Cabeza <: PartesDelCuerpo
    radio::Real
    centro::Array{Float64,1}
    cuello::Array{Float64,1}
    contorno::Array{Array{Float64,1}}    
end

mutable struct Pierna <: PartesDelCuerpo
    pelvis::Array{Float64,1}
    rodilla::Array{Float64,1}
    pie::Array{Float64,1}
    femur::Segmento  
    tibia::Segmento  
end

mutable struct Brazo <: PartesDelCuerpo
    hombro::Array{Float64,1}
    codo::Array{Float64,1}
    mano::Array{Float64,1}
    húmero::Segmento  
    cúbito::Segmento  
end

mutable struct Torso <: PartesDelCuerpo
    cuello::Array{Float64,1}
    pelvis::Array{Float64,1}
    tronco::Segmento   
end


mutable struct StickMan 
    cabeza::Cabeza
    brazoD::Brazo
    brazoI::Brazo
    torso::Torso
    piernaD::Pierna
    piernaI::Pierna
    centro::Array{Float64,1} #genralmete se tomará como las coordenadas de la pelvis
end


##############################################
######### Funciones generadoras ##############
##############################################


"""
Esta función genera un objeto Cabeza dados su radio y la posicíon de su cuello y el ángulo que forma el vector centro-cuello con la vertical (predefinido 0)
"""
function cabeza(radio::Float64,cuello::Array{Float64,1},ang = 0.0)

    centro = cuello + [sin(ang),cos(ang)].*radio
    #asumiremos que el cuello siempre estará en la parte de abajo de la cabeza
    
    x = [radio*cos(t)+centro[1] for t in 0:0.01:6.28]
    y = [radio*sin(t)+centro[2] for t in 0:0.01:6.28]
     
    contorno = [x,y]  
      
    return Cabeza(radio,centro,cuello,contorno)
end

"""
Esta función genera un objeto Pierna dada la posición de la pelvis, la longitud de sus segmentos y los ángulos que forman con el eje x positivo (sentido positivo en contra de las manecillas del reloj).
"""
function pierna(pelvis::Array{Float64,1},ang_pelvis::Float64,long_fem::Float64,ang_rodilla::Float64,long_tib::Float64)
    #long_fem,long_tib > 0
    rodilla = [cos(ang_pelvis),sin(ang_pelvis)].*long_fem + pelvis
    pie = [cos(ang_rodilla),sin(ang_rodilla)].*long_tib + rodilla
    femur = Segmento(pelvis,rodilla)
    tibia = Segmento(rodilla,pie)
    return Pierna(pelvis,rodilla,pie,femur,tibia)
end


"""
Esta función genera un objeto Brazo dada la posición del hombro, la longitud de sus segmentos y los ángulos que forman con el eje x positivo (sentido positivo en contra de las manecillas del reloj).
"""
function brazo(hombro::Array{Float64,1},ang_hombro::Float64,long_hum::Float64,ang_codo::Float64,long_cub::Float64)
    #long_hum,long_cub > 0
    codo = [cos(ang_hombro),sin(ang_hombro)].*long_hum + hombro
    mano = [cos(ang_codo),sin(ang_codo)].*long_cub + codo
    húmero = Segmento(hombro,codo)
    cúbito = Segmento(codo,mano)
    return Brazo(hombro,codo,mano,húmero,cúbito)
end

"""
Esta función genera un objeto Torso  dada la posición del cuello y de la pelvis
"""
function torso(cuello::Array{Float64,1},pelvis::Array{Float64,1})
        tronco = Segmento(cuello,pelvis)
    return Torso(cuello,pelvis,tronco)
end

###################################
#### Función de ploteo de partes del cuerpo 
##############################
using Plots
 
import Plots.plot!

function plot!(P::PartesDelCuerpo;alpha = 1.0, linewidth =0.5 , markersize=1.0, label = "", fill= false,color = :red)
    if P isa Cabeza
        plot!(P.contorno[1],P.contorno[2],alpha = alpha, linewidth = linewidth, markersize = markersize ,label=label, color = color,fill = fill)
    elseif P isa Pierna
        x = [P.pelvis[1],P.rodilla[1],P.pie[1]]
        y = [P.pelvis[2],P.rodilla[2],P.pie[2]]
        plot!(x,y,alpha = alpha, linewidth = linewidth, markersize = markersize ,label=label, color = color,fill = fill)
    elseif P isa Brazo
        x = [P.hombro[1],P.codo[1],P.mano[1]]
        y = [P.hombro[2],P.codo[2],P.mano[2]]
        plot!(x,y,alpha = alpha, linewidth = linewidth, markersize = markersize ,label=label, color = color,fill = fill)
    elseif P isa Torso
        x = [P.cuello[1],P.pelvis[1]]
        y = [P.cuello[2],P.pelvis[2]]
        plot!(x,y,alpha = alpha, linewidth = linewidth, markersize = markersize ,label=label, color = color,fill = fill)
    end
    
end
















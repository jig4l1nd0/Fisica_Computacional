#Objetos Fisica Computaciomal

using LinearAlgebra 

abstract type ObjetosGeométricos end

mutable struct Segmento <: ObjetosGeométricos
    punto_inicial::Array{Float64,1}
    punto_final::Array{Float64,1}
    longitud::Real
end

mutable struct Polígono <: ObjetosGeométricos
    vértices::Array{Array{Float64,1}}
    lados::Array{Segmento,1}
    número_de_lados::Int
    área::Real
    perímetro::Union{AbstractFloat,Int}    
end

mutable struct Poliedro <: ObjetosGeométricos
    vértices::Array{Array{Float64,1}}
    lados::Array{Segmento,1}
    caras::Array{Polígono,1}
end

function Segmento(a₁::Array{<:Real,1}, a₂::Array{<:Real,1}) #Definimos la función para arreglos de números reales
    return Segmento(a₁, a₂, norm(a₁ - a₂)) #Regresamos el objeto de tipo Segmento previamente definido
end   

"""
Esta función recibe un arreglo de arreglos de dimensión 1 con las coordenadas de los vértices
para generar un polígono. Regresa los mismos vértices, los lados, el número de lados, el área y el perímetro
"""
function Polígono(vértices::Array{Array{Float64,1},1})
    #Cuenta los vértices, ese el el número de lados
    número_de_lados = length(vértices)
    #Genera el arreglo de segmentos de los lados usando la función Segmento previamente definida
    lados = [Segmento(vértices[i], vértices[i+1]) for i ∈ 1:(número_de_lados-1)]
    push!(lados, Segmento(vértices[número_de_lados], vértices[1]))    
    #Calcula el perímetro como la suma de las longitudes de los lados
    perímetro = sum([lado.longitud for lado ∈ lados ])
    #Calcula el área usando la formula de Gauss o "fórmula de la agujeta"
    área = sum(vértices[i][1]*vértices[i+1][2] - vértices[i+1][1]*vértices[i][2] for i ∈ 1:(número_de_lados-1))
    área += vértices[número_de_lados][1]*vértices[1][2] - vértices[1][1]*vértices[número_de_lados][2]
    área /= 2
    return Polígono(vértices, lados, número_de_lados, área, perímetro)
end

import Base.+ #Importamos esto para poder modificar la función predefinida
"""
Esta función recibe como argumentos poligonos o segmentos (variables de tipo ObjetosGeométricos) 
y regresa un Polígono formado por los vértices de los objetos geométricos introducidos
"""
function +(ObjetGeométrico::ObjetosGeométricos...)
    
    Vértices::Array{Array{Float64,1},1} = [] #declaramos un arreglo vacío donde guardaremos 
                                             #los vértices del nuevo polígono
    
    for ObGe ∈ ObjetGeométrico #para cada objeto geométrico en la tupla...
                                
        if ObGe isa Segmento     #si el objeto es un segmento, extraemos el punto inicial y el punto final
                                 #se agregan  al arreglo Vértices
            Vértices = vcat(Vértices,[ObGe.punto_inicial,ObGe.punto_final]) 
        
        elseif ObGe isa Polígono #si el objeto es un polígono, extraemos el arreglo de sus vértices 
                                 #y se concatena al arreglo Vértices
            Vértices = vcat(Vértices,ObGe.vértices)
        else
            println("ERROR: debes introducir sólamente Objetos Geométricos")
            return -1
    
        end
    end
    return Polígono(Vértices) #la función regresa un polígono a partir del nuevo conjunto de vértices
end

import Plots.plot! #vamos a agregarle un nuevo método a plot
function plot!(ObjetoGeométrico::ObjetosGeométricos; Alpha = 1.0, Linewidth =0.5 , Markersize=1.0, Label = "", Fill= false,Color = :red)
        if ObjetoGeométrico isa Segmento
           if length(ObjetoGeométrico.punto_inicial) == 3 
            x = [ObjetoGeométrico.punto_inicial[1],ObjetoGeométrico.punto_final[1]]
            y = [ObjetoGeométrico.punto_inicial[2],ObjetoGeométrico.punto_final[2]]
            z = [ObjetoGeométrico.punto_inicial[3],ObjetoGeométrico.punto_final[3]]
            plot!(x,y,z, alpha = Alpha, linewidth = Linewidth, markersize = Markersize ,label=Label, color = Color)
           elseif length(ObjetoGeométrico.punto_inicial) == 2
            x = [ObjetoGeométrico.punto_inicial[1],ObjetoGeométrico.punto_final[1]]
            y = [ObjetoGeométrico.punto_inicial[2],ObjetoGeométrico.punto_final[2]]
            plot!(x,y, alpha = Alpha, linewidth = Linewidth, markersize = Markersize ,label=Label, color = Color)
           end 
        elseif ObjetoGeométrico isa Polígono    
          if length(ObjetoGeométrico.vértices[1]) == 3
            x = [ObjetoGeométrico.vértices[i][1] for i in 1:length(ObjetoGeométrico.vértices)]
            y = [ObjetoGeométrico.vértices[i][2] for i in 1:length(ObjetoGeométrico.vértices)]
            z = [ObjetoGeométrico.vértices[i][3] for i in 1:length(ObjetoGeométrico.vértices)]
            push!(x,ObjetoGeométrico.vértices[1][1])
            push!(y,ObjetoGeométrico.vértices[1][2])    #Agregamos el prmer vértice al final para cerrar la figura
            push!(z,ObjetoGeométrico.vértices[1][3])
            if Fill
                surface!(x,y,z,alpha = Alpha)    
            else
                plot!(x,y,z, alpha = Alpha, linewidth = Linewidth, markersize = Markersize ,label=Label, color = Color)
            end
          elseif length(ObjetoGeométrico.vértices[1]) == 2
            x = [ObjetoGeométrico.vértices[i][1] for i in 1:length(ObjetoGeométrico.vértices)]
            y = [ObjetoGeométrico.vértices[i][2] for i in 1:length(ObjetoGeométrico.vértices)]
            push!(x,ObjetoGeométrico.vértices[1][1])
            push!(y,ObjetoGeométrico.vértices[1][2])    #Agregamos el prmer vértice al final para cerrar la figura
            plot!(x,y, alpha = Alpha, linewidth = Linewidth, markersize = Markersize ,label=Label, color = Color,fill = Fill) 
          end
        end
end     

defmodule Mailer.Template.Locator do

  def locate(template_name, country_code) do                                                                                                     
    file_types = [text: ".txt", html: ".html"]

    Enum.reduce(file_types, [], fn({file_type, ext}, acc) ->
      x = locate(template_name, country_code, ext) 

      case x do
        nil ->
          acc
        x ->
          [{file_type, x} | acc]
      end
    end)
  end

  defp locate(template_name, country_code, ext) do
    case maybe_locate(template_name, country_code, ext) do
      nil ->                                  
        maybe_locate(template_name, "", ext)        
      found ->                               
        found                                
    end                                      
  end

  defp maybe_locate(template_name, country_code, ext) do
    template_location = Application.get_env(:mailer, :templates)
      |> Path.join(template_name)            
      |> Path.join(country_code)             
      |> Path.join("#{template_name}#{ext}")     


    case File.exists?(template_location) do
      true ->
        template_location
      _ ->
        nil
    end
  end
end

#load ".fake/build.fsx/intellisense.fsx"

#r "paket:
nuget Fake.IO.FileSystem
nuget Fake.DotNet
nuget Fake.DotNet.Cli
nuget Fake.Core
nuget Fake.DotNet.MSBuild
nuget FSharp.Data 3.0.0-rc
nuget Newtonsoft.Json
nuget Fake.Core.Target \\"

open Fake.Core
open Fake.IO
open Fake.Core.TargetOperators
open FSharp.Data
open System.IO
open Newtonsoft.Json
open Newtonsoft.Json.Serialization

let newFile = __SOURCE_DIRECTORY__ + @"/../public/data/NorskeFjell1000m.json"

type GeoProps = {
    Navn: string
    Kommune: string
    Kommunenr: int
    Fylke: string
    Hoyde: int
}
type GeoGeometry = {
    Type: string
    Coordinates: decimal array
}
type GeoJsonItem = {
    Type: string
    Properties: GeoProps
    Geometry: GeoGeometry
}

type GeoJson = {Type: string; Features: GeoJsonItem array}

let write data = 
    let settings =  JsonSerializerSettings()
    settings.ContractResolver <- CamelCasePropertyNamesContractResolver()
    File.WriteAllText(newFile, JsonConvert.SerializeObject(data, settings))

let path = "https://www.erikbolstad.no/geo/noreg/norske-fjell-over-1000-meter/"

type Document = HtmlProvider<"https://www.erikbolstad.no/geo/noreg/norske-fjell-over-1000-meter/">

let documentData = Document.Load(path)

let createGeoFjell (data: Document.NorskeFjellOver1000Meter.Row) =
                {
                Type = "Feature"
                Properties = { Navn = data.Namn; Kommune = data.Kommune; Kommunenr = data.Kommunenr; Fylke = data.Fylke; Hoyde = data.``Høgde over havet``}
                Geometry = {Type = "Point"; Coordinates = [|data.Lon; data.Lat|]}
                }


let processMountains = documentData.Tables.``Norske fjell over 1000 meter``.Rows
                    |> Seq.map (createGeoFjell)
                    |> Seq.toArray
                    |> (fun x -> {Type = "FeatureCollection"; Features = x})
                    |> write
            


Target.create "ProcessMountains" (fun _ ->
    processMountains
)


Target.create "All" ignore

"ProcessMountains"
  ==> "All"

Target.runOrDefault "All"

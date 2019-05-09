param(
  [switch]$excludeProblemInstances = $false,
  [string]$outFile = 'HeuristicLab.OneCore.csproj',
  [string]$encoding = 'utf8',
  [string[]]$path = $pwd, # e.g. .,..\branches\my_branch,..\branches\another_branch
  [string]$excludeDirs = '\.\\[^\\]*$|.*(bin\\|obj\\|HeuristicLab\\|HeuristicLab\.(Clients\..*|.*\.Views.*|CodeEditor|MainForm.*|ExtLibs|Optimizer|Services\..*|Tests)\\).*'
)

$PSDefaultParameterValues['Out-File:Encoding'] = $encoding

'<?xml version="1.0" encoding="utf-8"?>
<Project ToolsVersion="15.0" xmlns="http://schemas.microsoft.com/developer/msbuild/2003">
  <Import Project="$(MSBuildExtensionsPath)\$(MSBuildToolsVersion)\Microsoft.Common.props" Condition="Exists(''$(MSBuildExtensionsPath)\$(MSBuildToolsVersion)\Microsoft.Common.props'')" />
  <PropertyGroup>
    <Configuration Condition=" ''$(Configuration)'' == '''' ">Debug</Configuration>
    <Platform Condition=" ''$(Platform)'' == '''' ">AnyCPU</Platform>
    <ProjectGuid>{22E197BD-8951-4737-A85F-F1BFEC799516}</ProjectGuid>
    <OutputType>Library</OutputType>
    <AppDesignerFolder>Properties</AppDesignerFolder>
    <RootNamespace>HeuristicLab.OneCore</RootNamespace>
    <AssemblyName>HeuristicLab.OneCore</AssemblyName>
    <TargetFrameworkVersion>v4.6.1</TargetFrameworkVersion>
    <FileAlignment>512</FileAlignment>
  </PropertyGroup>
  <PropertyGroup Condition=" ''$(Configuration)|$(Platform)'' == ''Debug|AnyCPU'' ">
    <DebugSymbols>true</DebugSymbols>
    <DebugType>full</DebugType>
    <Optimize>false</Optimize>
    <OutputPath>bin\Debug\</OutputPath>
    <DefineConstants>TRACE;DEBUG</DefineConstants>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
    <AllowUnsafeBlocks>true</AllowUnsafeBlocks>
    <NoWarn>
    </NoWarn>
  </PropertyGroup>
  <PropertyGroup Condition=" ''$(Configuration)|$(Platform)'' == ''Release|AnyCPU'' ">
    <DebugType>pdbonly</DebugType>
    <Optimize>true</Optimize>
    <OutputPath>bin\Release\</OutputPath>
    <DefineConstants>TRACE</DefineConstants>
    <ErrorReport>prompt</ErrorReport>
    <WarningLevel>4</WarningLevel>
  </PropertyGroup>
  <PropertyGroup>
    <SignAssembly>true</SignAssembly>
  </PropertyGroup>
  <PropertyGroup>
    <AssemblyOriginatorKeyFile>HeuristicLab\3.3\HeuristicLab.snk</AssemblyOriginatorKeyFile>
  </PropertyGroup>
  <ItemGroup>
    <Reference Include="ALGLIB-3.7.0">
      <HintPath>bin\ALGLIB-3.7.0.dll</HintPath>
    </Reference>
    <Reference Include="AutoDiff-1.0">
      <HintPath>bin\AutoDiff-1.0.dll</HintPath>
    </Reference>
    <Reference Include="DotNetScilab-1.0">
      <HintPath>bin\DotNetScilab-1.0.dll</HintPath>
    </Reference>
    <Reference Include="EPPlus-4.0.3">
      <HintPath>bin\EPPlus-4.0.3.dll</HintPath>
    </Reference>
    <Reference Include="Google.ProtocolBuffers-2.4.1.473">
      <HintPath>bin\Google.ProtocolBuffers-2.4.1.473.dll</HintPath>
    </Reference>
    <Reference Include="Interop.MLApp">
      <HintPath>bin\Interop.MLApp.dll</HintPath>
      <EmbedInteropTypes>True</EmbedInteropTypes>
    </Reference>
    <Reference Include="LibSVM-3.12">
      <HintPath>bin\LibSVM-3.12.dll</HintPath>
    </Reference>
    <Reference Include="Mono.Cecil-0.9.5">
      <HintPath>bin\Mono.Cecil-0.9.5.dll</HintPath>
    </Reference>
    <Reference Include="System" />
    <Reference Include="System.Core" />
    <Reference Include="System.Data.Linq" />
    <Reference Include="System.Drawing" />
    <Reference Include="System.IdentityModel" />
    <Reference Include="System.IO.Compression" />
    <Reference Include="System.Runtime.Serialization" />
    <Reference Include="System.Security" />
    <Reference Include="System.ServiceModel" />
    <Reference Include="System.Windows.Forms" />
    <Reference Include="System.Windows.Forms.DataVisualization" />
    <Reference Include="System.Xml.Linq" />
    <Reference Include="System.Data.DataSetExtensions" />
    <Reference Include="Microsoft.CSharp" />
    <Reference Include="System.Data" />
    <Reference Include="System.Net.Http" />
    <Reference Include="System.Xml" />
  </ItemGroup>
  <ItemGroup>
    <Compile Include=".\HeuristicLab\3.3\Properties\AssemblyInfo.cs" />' | Out-File $outFile

$activity = "Generating $($outFile)"

Get-ChildItem -Path $path -File -Recurse -Filter '*.cs' `
  | % { $_.FullName } `
  | Resolve-Path -Relative `
  | ? { ($_ -replace "\$([IO.Path]::DirectorySeparatorChar)", '\') -notmatch "$($excludeDirs)|.*\\(Plugin|AssemblyInfo)\.cs" } `
  | % { Write-Progress -Activity $activity -Status 'Adding Compile entries' -CurrentOperation $_; $_ } `
  | % { "    <Compile Include=""$($_)"" />" } `
  | Out-File $outFile -Append

'  </ItemGroup>
  <ItemGroup>' | Out-File $outFile -Append

Get-ChildItem -Path $path -File -Recurse `
  | ? { $_.Extension -in '.dll', '.ico', '.png', '.svg', '.txt' } `
  | % { $_.FullName } `
  | Resolve-Path -Relative `
  | ? { $_ -replace "\$([IO.Path]::DirectorySeparatorChar)", '\' -notmatch $excludeDirs } `
  | % { Write-Progress -Activity $activity -Status 'Adding Content entries' -CurrentOperation $_; $_ } `
  | % { "    <Content Include=""$($_ -replace '&', '&amp;')"" />" } `
  | Out-File $outFile -Append

'  </ItemGroup>
  <ItemGroup>' | Out-File $outFile -Append

$embeddedResourcesExtensions = @('.resx')
if (!$excludeProblemInstances) {
  $embeddedResourcesExtensions += '.zip'
}

Get-ChildItem -Path $path -File -Recurse `
  | ? { $_.Extension -in $embeddedResourcesExtensions } `
  | % { $_.FullName } `
  | Resolve-Path -Relative `
  | ? { $_ -replace "\$([IO.Path]::DirectorySeparatorChar)", '\' -notmatch $excludeDirs } `
  | % { Write-Progress -Activity $activity -Status 'Adding EmbeddedResource entries' -CurrentOperation $_; $_ } `
  | % { "    <EmbeddedResource Include=""$($_)"" />" } `
  | Out-File $outFile -Append

'  </ItemGroup>
  <ItemGroup>
    <None Include="HeuristicLab\3.3\HeuristicLab.snk" />
  </ItemGroup>
  <Import Project="$(MSBuildToolsPath)\Microsoft.CSharp.targets" />
</Project>' | Out-File $outFile -Append

Write-Progress -Activity $activity -Completed
using UnrealBuildTool;
using System.Collections.Generic;

public class LastZoneEditorTarget : TargetRules
{
    public LastZoneEditorTarget(TargetInfo Target) : base(Target)
    {
        Type = TargetType.Editor;
        DefaultBuildSettings = BuildSettingsVersion.V5;
        IncludeOrderVersion = EngineIncludeOrderVersion.Latest;
        ExtraModuleNames.Add("LastZone");
    }
}
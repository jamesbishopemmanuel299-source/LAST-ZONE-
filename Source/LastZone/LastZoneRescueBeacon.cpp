#include "LastZoneRescueBeacon.h"
#include "LastZoneCharacter.h"
#include "Components/StaticMeshComponent.h"
#include "Engine/StaticMesh.h"

ALastZoneRescueBeacon::ALastZoneRescueBeacon()
{
    PrimaryActorTick.bCanEverTick = false;
    Visual = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("BeaconVisual"));
    RootComponent = Visual;
    Visual->SetStaticMesh(LoadObject<UStaticMesh>(nullptr, TEXT("/Engine/BasicShapes/Cylinder.Cylinder")));
    Visual->SetRelativeScale3D(FVector(0.8f, 0.8f, 1.8f));
    Visual->SetCollisionProfileName(TEXT("BlockAll"));
}

void ALastZoneRescueBeacon::TryActivate(ALastZoneCharacter* Player)
{
    if (Player) Player->ActivateRescueBeacon();
}
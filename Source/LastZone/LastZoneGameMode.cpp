#include "LastZoneGameMode.h"
#include "LastZoneCharacter.h"
#include "LastZoneCollectible.h"
#include "LastZoneRescueBeacon.h"
#include "LastZonePatrolScout.h"
#include "Engine/World.h"
#include "Engine/StaticMesh.h"
#include "Components/StaticMeshComponent.h"

ALastZoneGameMode::ALastZoneGameMode()
{
    DefaultPawnClass = ALastZoneCharacter::StaticClass();
    PrimaryActorTick.bCanEverTick = false;
}

void ALastZoneGameMode::BeginPlay()
{
    Super::BeginPlay();
    BuildPrototypeIsland();
}

void ALastZoneGameMode::BuildPrototypeIsland()
{
    UStaticMesh* Cube = LoadObject<UStaticMesh>(nullptr, TEXT("/Engine/BasicShapes/Cube.Cube"));
    if (Cube)
    {
        AActor* Ground = GetWorld()->SpawnActor<AActor>(FVector(0,0,-160), FRotator::ZeroRotator);
        if (Ground)
        {
            UStaticMeshComponent* GroundMesh = NewObject<UStaticMeshComponent>(Ground);
            Ground->SetRootComponent(GroundMesh);
            GroundMesh->SetStaticMesh(Cube);
            GroundMesh->SetWorldScale3D(FVector(130.f,130.f,3.f));
            GroundMesh->SetCollisionProfileName(TEXT("BlockAll"));
            GroundMesh->RegisterComponent();
        }

        for (int32 i = 0; i < 12; ++i)
        {
            const float Angle = 2.f * PI * i / 12.f;
            const FVector Location(FMath::Cos(Angle)*5600.f, FMath::Sin(Angle)*5600.f, 180.f);
            AActor* Marker = GetWorld()->SpawnActor<AActor>(Location, FRotator::ZeroRotator);
            if (!Marker) continue;
            UStaticMeshComponent* Mesh = NewObject<UStaticMeshComponent>(Marker);
            Marker->SetRootComponent(Mesh);
            Mesh->SetStaticMesh(Cube);
            Mesh->SetWorldScale3D(FVector(2.f,2.f,6.f));
            Mesh->SetCollisionProfileName(TEXT("BlockAll"));
            Mesh->RegisterComponent();
        }
    }

    for (int32 i = 0; i < SupplyCacheCount; ++i)
    {
        const float Angle = i * 2.39996f;
        const float Radius = 850.f + i * 720.f;
        const FVector Location(FMath::Cos(Angle)*Radius, FMath::Sin(Angle)*Radius, 120.f);
        GetWorld()->SpawnActor<ALastZoneCollectible>(
            ALastZoneCollectible::StaticClass(), Location, FRotator::ZeroRotator);
    }

    GetWorld()->SpawnActor<ALastZoneRescueBeacon>(
        ALastZoneRescueBeacon::StaticClass(), FVector(0,0,180), FRotator::ZeroRotator);

    GetWorld()->SpawnActor<ALastZonePatrolScout>(
        ALastZonePatrolScout::StaticClass(), FVector(1200.f, 900.f, 300.f), FRotator::ZeroRotator);
}
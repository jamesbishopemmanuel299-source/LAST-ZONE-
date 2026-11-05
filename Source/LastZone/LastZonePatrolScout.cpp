#include "LastZonePatrolScout.h"
#include "Components/StaticMeshComponent.h"
#include "Engine/StaticMesh.h"
#include "Kismet/GameplayStatics.h"
#include "LastZoneCharacter.h"

ALastZonePatrolScout::ALastZonePatrolScout()
{
    PrimaryActorTick.bCanEverTick = true;
    ScoutMesh = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("ScoutMesh"));
    RootComponent = ScoutMesh;
    ScoutMesh->SetCollisionEnabled(ECollisionEnabled::NoCollision);
    ScoutMesh->SetRelativeScale3D(FVector(0.8f, 0.8f, 0.35f));
}

void ALastZonePatrolScout::BeginPlay()
{
    Super::BeginPlay();
    Origin = GetActorLocation();
    if (UStaticMesh* Sphere = LoadObject<UStaticMesh>(nullptr, TEXT("/Engine/BasicShapes/Sphere.Sphere")))
        ScoutMesh->SetStaticMesh(Sphere);
}

void ALastZonePatrolScout::Tick(float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);
    UpdatePatrol(DeltaSeconds);
    CheckForPlayer();
}

void ALastZonePatrolScout::UpdatePatrol(float DeltaSeconds)
{
    PatrolPhase += DeltaSeconds * 0.45f;
    const FVector Offset(FMath::Cos(PatrolPhase) * 650.f, FMath::Sin(PatrolPhase * 0.7f) * 420.f, 120.f);
    const FVector Next = Origin + Offset;
    SetActorLocation(FMath::VInterpTo(GetActorLocation(), Next, DeltaSeconds, 1.4f));
    const FVector Direction = (Next - GetActorLocation()).GetSafeNormal();
    if (!Direction.IsNearlyZero()) SetActorRotation(Direction.Rotation());
}

void ALastZonePatrolScout::CheckForPlayer()
{
    ALastZoneCharacter* Player = Cast<ALastZoneCharacter>(UGameplayStatics::GetPlayerCharacter(this, 0));
    if (!Player) return;
    const float Distance = FVector::Dist(GetActorLocation(), Player->GetActorLocation());
    const FVector ToPlayer = (Player->GetActorLocation() - GetActorLocation()).GetSafeNormal();
    const bool bInViewCone = FVector::DotProduct(GetActorForwardVector(), ToPlayer) > 0.45f;
    FHitResult SightHit;
    FCollisionQueryParams Params;
    Params.AddIgnoredActor(this);
    const bool bClearSight = !GetWorld()->LineTraceSingleByChannel(
        SightHit, GetActorLocation(), Player->GetActorLocation(), ECC_Visibility, Params)
        || SightHit.GetActor() == Player;
    const bool bDetected = Distance < (Player->bStealthMode ? 500.f : 1050.f) && bInViewCone && bClearSight;
    if (bDetected != bWasAlerted)
    {
        bWasAlerted = bDetected;
        Player->SetScoutAlert(bWasAlerted);
    }
}
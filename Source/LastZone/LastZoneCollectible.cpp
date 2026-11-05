#include "LastZoneCollectible.h"
#include "LastZoneCharacter.h"
#include "Components/SphereComponent.h"
#include "Components/StaticMeshComponent.h"
#include "Engine/StaticMesh.h"

ALastZoneCollectible::ALastZoneCollectible()
{
    PrimaryActorTick.bCanEverTick = false;
    Trigger = CreateDefaultSubobject<USphereComponent>(TEXT("PickupTrigger"));
    RootComponent = Trigger;
    Trigger->InitSphereRadius(105.f);
    Trigger->SetCollisionProfileName(TEXT("OverlapAllDynamic"));
    Trigger->OnComponentBeginOverlap.AddDynamic(this, &ALastZoneCollectible::OnOverlap);

    Visual = CreateDefaultSubobject<UStaticMeshComponent>(TEXT("SupplyVisual"));
    Visual->SetupAttachment(RootComponent);
    Visual->SetStaticMesh(LoadObject<UStaticMesh>(nullptr, TEXT("/Engine/BasicShapes/Sphere.Sphere")));
    Visual->SetRelativeScale3D(FVector(0.55f));
    Visual->SetCollisionEnabled(ECollisionEnabled::NoCollision);
}

void ALastZoneCollectible::BeginPlay()
{
    Super::BeginPlay();
}

void ALastZoneCollectible::OnOverlap(UPrimitiveComponent*, AActor* OtherActor,
    UPrimitiveComponent*, int32, bool, const FHitResult&)
{
    if (ALastZoneCharacter* Player = Cast<ALastZoneCharacter>(OtherActor))
    {
        Player->AddSupply(1);
        Destroy();
    }
}
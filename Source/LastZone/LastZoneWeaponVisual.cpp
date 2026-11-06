#include "LastZoneWeaponVisual.h"
#include "Components/SceneComponent.h"
#include "Components/StaticMeshComponent.h"
#include "UObject/ConstructorHelpers.h"

ALastZoneWeaponVisual::ALastZoneWeaponVisual()
{
    PrimaryActorTick.bCanEverTick = true;
    SceneRoot = CreateDefaultSubobject<USceneComponent>(TEXT("SceneRoot"));
    SetRootComponent(SceneRoot);

    static ConstructorHelpers::FObjectFinder<UStaticMesh> CubeMesh(TEXT("/Engine/BasicShapes/Cube.Cube"));
    static ConstructorHelpers::FObjectFinder<UStaticMesh> SphereMesh(TEXT("/Engine/BasicShapes/Sphere.Sphere"));
    static ConstructorHelpers::FObjectFinder<UStaticMesh> CylinderMesh(TEXT("/Engine/BasicShapes/Cylinder.Cylinder"));

    auto MakePart = [this](const TCHAR* Name, UStaticMesh* Mesh, FVector Location, FVector Scale)
    {
        UStaticMeshComponent* Part = CreateDefaultSubobject<UStaticMeshComponent>(Name);
        Part->SetupAttachment(SceneRoot);
        if (Mesh) Part->SetStaticMesh(Mesh);
        Part->SetRelativeLocation(Location);
        Part->SetRelativeScale3D(Scale);
        Part->SetCollisionEnabled(ECollisionEnabled::NoCollision);
        Part->SetCastShadow(true);
        return Part;
    };

    MainShell = MakePart(TEXT("MainShell"), CubeMesh.Object, FVector(24.f, 0.f, 0.f), FVector(0.82f, 0.19f, 0.16f));
    UpperSpine = MakePart(TEXT("UpperSpine"), CubeMesh.Object, FVector(22.f, 0.f, 13.f), FVector(0.56f, 0.12f, 0.045f));
    EnergyCore = MakePart(TEXT("EnergyCore"), SphereMesh.Object, FVector(5.f, 0.f, 1.f), FVector(0.22f, 0.21f, 0.21f));
    FrontEmitter = MakePart(TEXT("FrontEmitter"), CylinderMesh.Object, FVector(61.f, 0.f, 1.f), FVector(0.12f, 0.12f, 0.12f));
    Grip = MakePart(TEXT("Grip"), CubeMesh.Object, FVector(2.f, 0.f, -19.f), FVector(0.17f, 0.13f, 0.31f));
    SideModule = MakePart(TEXT("SideModule"), CubeMesh.Object, FVector(27.f, 17.f, -1.f), FVector(0.28f, 0.055f, 0.095f));

    BaseLocation = FVector::ZeroVector;
    BaseRotation = FRotator::ZeroRotator;
}

void ALastZoneWeaponVisual::Tick(float DeltaSeconds)
{
    Super::Tick(DeltaSeconds);
    AnimationTime += DeltaSeconds;
    FireKick = FMath::FInterpTo(FireKick, 0.f, DeltaSeconds, 14.f);
    ReloadBlend = FMath::FInterpTo(ReloadBlend, 0.f, DeltaSeconds, 3.5f);

    const float IdleBob = FMath::Sin(AnimationTime * 2.2f) * 0.65f;
    SetActorRelativeLocation(BaseLocation + FVector(0.f, 0.f, IdleBob - ReloadBlend * 5.f));
    SetActorRelativeRotation(BaseRotation + FRotator(ReloadBlend * 17.f, 0.f, FireKick * 2.f));

    if (EnergyCore)
    {
        const float Pulse = 1.f + 0.08f * FMath::Sin(AnimationTime * 5.f);
        EnergyCore->SetRelativeScale3D(FVector(0.22f, 0.21f, 0.21f) * Pulse);
    }
}

void ALastZoneWeaponVisual::PlayFireAnimation()
{
    FireKick = 5.5f;
}

void ALastZoneWeaponVisual::PlayReloadAnimation()
{
    ReloadBlend = 1.f;
}

void ALastZoneWeaponVisual::SetWeaponStyle(int32 StyleIndex)
{
    CurrentStyle = FMath::Abs(StyleIndex) % 10;
    const float Width = 0.17f + (CurrentStyle % 3) * 0.025f;
    if (MainShell) MainShell->SetRelativeScale3D(FVector(0.82f, Width, 0.16f));
    if (UpperSpine) UpperSpine->SetRelativeScale3D(FVector(0.56f, 0.12f + (CurrentStyle % 2) * 0.025f, 0.045f));
    if (SideModule) SideModule->SetRelativeLocation(FVector(27.f, 17.f, -1.f + (CurrentStyle % 4) * 1.5f));
}

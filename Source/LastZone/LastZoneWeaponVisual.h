#pragma once

#include "CoreMinimal.h"
#include "GameFramework/Actor.h"
#include "LastZoneWeaponVisual.generated.h"

class UStaticMeshComponent;
class USceneComponent;

/** Procedural-looking, fictional sci-fi weapon assembled from simple engine meshes. */
UCLASS()
class LASTZONE_API ALastZoneWeaponVisual : public AActor
{
    GENERATED_BODY()

public:
    ALastZoneWeaponVisual();
    virtual void Tick(float DeltaSeconds) override;

    UFUNCTION(BlueprintCallable, Category="Weapon Visual")
    void PlayFireAnimation();

    UFUNCTION(BlueprintCallable, Category="Weapon Visual")
    void PlayReloadAnimation();

    UFUNCTION(BlueprintCallable, Category="Weapon Visual")
    void SetWeaponStyle(int32 StyleIndex);

private:
    UPROPERTY()
    TObjectPtr<USceneComponent> SceneRoot;

    UPROPERTY()
    TObjectPtr<UStaticMeshComponent> MainShell;

    UPROPERTY()
    TObjectPtr<UStaticMeshComponent> UpperSpine;

    UPROPERTY()
    TObjectPtr<UStaticMeshComponent> EnergyCore;

    UPROPERTY()
    TObjectPtr<UStaticMeshComponent> FrontEmitter;

    UPROPERTY()
    TObjectPtr<UStaticMeshComponent> Grip;

    UPROPERTY()
    TObjectPtr<UStaticMeshComponent> SideModule;

    FVector BaseLocation;
    FRotator BaseRotation;
    float AnimationTime = 0.f;
    float FireKick = 0.f;
    float ReloadBlend = 0.f;
    int32 CurrentStyle = 0;
};

#pragma once

#include "CoreMinimal.h"
#include "GameFramework/GameModeBase.h"
#include "LastZoneGameMode.generated.h"

UCLASS()
class LASTZONE_API ALastZoneGameMode : public AGameModeBase
{
    GENERATED_BODY()
public:
    ALastZoneGameMode();
    virtual void BeginPlay() override;

    UPROPERTY(EditDefaultsOnly, Category="Island")
    int32 SupplyCacheCount = 5;

private:
    void BuildPrototypeIsland();
};
#pragma once

#include "CoreMinimal.h"
#include "Blueprint/UserWidget.h"
#include "LastZoneInventoryWidget.generated.h"

class ULastZoneArsenalComponent;
class UHorizontalBox;
class UButton;
class UTextBlock;

UCLASS()
class LASTZONE_API ULastZoneInventoryWidget : public UUserWidget
{
    GENERATED_BODY()

public:
    UFUNCTION(BlueprintCallable, Category="Inventory")
    void SetArsenalComponent(ULastZoneArsenalComponent* InArsenal);

    UFUNCTION(BlueprintCallable, Category="Inventory")
    void RefreshInventory();

protected:
    virtual void NativeConstruct() override;

private:
    UPROPERTY()
    TObjectPtr<ULastZoneArsenalComponent> Arsenal;

    UPROPERTY()
    TObjectPtr<UHorizontalBox> SlotRow;

    UPROPERTY()
    TArray<TObjectPtr<UButton>> SlotButtons;

    UPROPERTY()
    TArray<TObjectPtr<UTextBlock>> SlotLabels;

    void BuildSlots();
    void EquipSlot(int32 SlotIndex);
};

#include "LastZoneInventoryWidget.h"
#include "LastZoneArsenalComponent.h"
#include "Components/HorizontalBox.h"
#include "Components/HorizontalBoxSlot.h"
#include "Components/Button.h"
#include "Components/TextBlock.h"
#include "Components/Border.h"
#include "Blueprint/WidgetTree.h"

void ULastZoneInventoryWidget::NativeConstruct()
{
    Super::NativeConstruct();
    BuildSlots();
    RefreshInventory();
}

void ULastZoneInventoryWidget::SetArsenalComponent(ULastZoneArsenalComponent* InArsenal)
{
    Arsenal = InArsenal;
    RefreshInventory();
}

void ULastZoneInventoryWidget::BuildSlots()
{
    if (!WidgetTree || SlotRow) return;
    UBorder* Panel = WidgetTree->ConstructWidget<UBorder>(UBorder::StaticClass(), TEXT("InventoryPanel"));
    Panel->SetPadding(FMargin(7.f));
    Panel->SetBrushColor(FLinearColor(0.015f, 0.035f, 0.07f, 0.86f));
    WidgetTree->RootWidget = Panel;

    SlotRow = WidgetTree->ConstructWidget<UHorizontalBox>(UHorizontalBox::StaticClass(), TEXT("WeaponSlots"));
    Panel->SetContent(SlotRow);

    for (int32 i = 0; i < 5; ++i)
    {
        UButton* Button = WidgetTree->ConstructWidget<UButton>(UButton::StaticClass());
        Button->SetBackgroundColor(FLinearColor(0.035f, 0.12f, 0.19f, 0.96f));
        UTextBlock* Label = WidgetTree->ConstructWidget<UTextBlock>(UTextBlock::StaticClass());
        Label->SetText(FText::FromString(TEXT("EMPTY")));
        Label->SetJustification(ETextJustify::Center);
        Label->SetAutoWrapText(true);
        Button->SetContent(Label);
        SlotRow->AddChildToHorizontalBox(Button);
        if (UHorizontalBoxSlot* Slot = Cast<UHorizontalBoxSlot>(Button->Slot))
        {
            Slot->SetPadding(FMargin(4.f));
            Slot->SetSize(FSlateChildSize(ESlateSizeRule::Fill));
        }
        Button->OnClicked.AddLambda([this, i]() { EquipSlot(i); });
        SlotButtons.Add(Button);
        SlotLabels.Add(Label);
    }
}

void ULastZoneInventoryWidget::RefreshInventory()
{
    if (!Arsenal || SlotLabels.Num() == 0) return;
    const int32 Count = Arsenal->Arsenal.Num();
    for (int32 Slot = 0; Slot < SlotLabels.Num(); ++Slot)
    {
        const int32 WeaponIndex = Slot;
        if (Arsenal->Arsenal.IsValidIndex(WeaponIndex))
        {
            const FLastZoneWeaponData& Weapon = Arsenal->Arsenal[WeaponIndex];
            const FString Marker = WeaponIndex == Arsenal->EquippedIndex ? TEXT("[EQUIPPED]\n") : TEXT("");
            const FString Text = FString::Printf(TEXT("%s%s\n%s\nAMMO %d"),
                *Marker, *Weapon.DisplayName.ToString(), *Weapon.Rarity.ToString(),
                WeaponIndex == Arsenal->EquippedIndex ? Arsenal->AmmoInMagazine : Weapon.MagazineSize);
            SlotLabels[Slot]->SetText(FText::FromString(Text));
            SlotButtons[Slot]->SetIsEnabled(true);
        }
        else
        {
            SlotLabels[Slot]->SetText(FText::FromString(TEXT("EMPTY SLOT")));
            SlotButtons[Slot]->SetIsEnabled(false);
        }
    }
}

void ULastZoneInventoryWidget::EquipSlot(int32 SlotIndex)
{
    if (!Arsenal || !Arsenal->Arsenal.IsValidIndex(SlotIndex)) return;
    while (Arsenal->EquippedIndex != SlotIndex) Arsenal->EquipNext();
    RefreshInventory();
}

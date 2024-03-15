<template>
  <div
    class="box w-[150px] h-fit m-5 text-center rounded-md"
    :class="[
      // box.isSendBox && 'outline-blue-500 outline-dashed',
      box.parent && 'ml-10',
      box.boxes.length && 'border-l-2 border-dashed border-blue-300',
    ].join(' ')"
    :draggable="box.draggable"
    :hidden="box.isHide"

    @dragstart="() => box.draggable && onDragStart(box)"
    @dragenter.prevent="() => box.draggable && onDragEnter(box)"
    @dragleave="() => box.draggable && onDragLeave(box)"
    @dragover.prevent="box.draggable && onDragOver(box)"
    @dragend.prevent="() => box.draggable && onDragEnd(box)"
    @drop.prevent="() => box.draggable && onDrop(box)"
  >
    <div
      class="item w-[150px] max-h-[40px] h-[40px] text-center rounded-md"
      :class="[
        // box.isSendBox && 'invisible',
        box.isHover && 'outline-blue-500 outline-dashed',
        box.isEmpty && 'outline-blue-500 outline-dashed',
        !box.isEmpty && 'bg-blue-200 cursor-pointer',
        box.isSelected && 'bg-blue-400 shadow-lg shadow-blue-500/50',
        (!box.draggable && !box.isEmpty) && 'hover:bg-blue-300 shadow-lg hover:shadow-blue-500/50'
      ]"
      :draggable="(!box.isEmpty && !box.draggable) && box?.item?.draggable"
      :hidden="box?.item?.isHide"

      @dragstart="() => (!box.draggable && box?.item?.draggable) && onDragStart(box)"
      @dragenter.prevent="() => (!box.draggable && box?.item?.draggable) && onDragEnter(box)"
      @dragleave="() => (!box.draggable && box?.item?.draggable) && onDragLeave(box)"
      @dragover.prevent="(!box.draggable && box?.item?.draggable) && onDragOver"
      @dragend.prevent="() => (!box.draggable && box?.item?.draggable) && onDragEnd(box)"
      @drop.prevent="() => (!box.draggable && box?.item?.draggable) && onDrop(box)"

      @click="() => onClickBox(box)"
    >
      <span v-if="!box.isEmpty">
        {{ box?.parent && (box.parent.item.label + ' / ') }}{{ box.item.label }}
      </span>
    </div>

    <Box
      v-for="boxChild in box.boxes"
      :key="boxChild.id"
      :box="boxChild"

      :onDragStart="onDragStart"
      :onDragEnter="onDragEnter"
      :onDragOver="onDragOver"
      :onDragLeave="onDragLeave"
      :onDragEnd="onDragEnd"
      :onDrop="onDrop"

      :onClickBox="onClickBox"
    />
  </div>
</template>

<script lang="ts" setup>
import { BoxProps, } from "./DragMenu.vue";
import { defineProps, } from "vue";

/**
 * @param classes Optional classes to customize the appearance to the box.
 * @param classes.box.class box w-[150px] h-fit m-5 text-center rounded-md
 * @param classes.box.whenHaveParent ml-10
 * @param classes.box.whenHaveChildren border-l-2 border-dashed border-blue-300
 *
 * @param classes.item.isHover outline-blue-500 outline-dashed
 * @param classes.item.isEmpty outline-blue-500 outline-dashed
 * @param classes.item.isNotEmpty bg-blue-200 cursor-pointer
 * @param classes.item.isSelected bg-blue-400 shadow-lg shadow-blue-500/50
 * @param classes.item.notDraggable hover:bg-blue-300 shadow-lg hover:shadow-blue-500/50
 *
*/
export interface BoxComponentProps {
  box: BoxProps;

  onDragStart: (box: BoxProps) => void;
  onDragEnter: (box: BoxProps) => void;
  onDragOver: (box: BoxProps) => void;
  onDragLeave: (box: BoxProps) => void;
  onDragEnd: (box: BoxProps) => void;
  onDrop: (box: BoxProps) => void;
  onClickBox: (box: BoxProps) => void;

  /**
   * Optional classes to customize the appearance of the components.
  */
  classes?: {
    box: {
      class: string;
      parent: string;
      whenHaveChildren: string;
    };
    item: {
      class: string;
      isHover: string;
      isEmpty: string;
      isNotEmpty: string;
      isSelected: string;
      notDraggable: string;
    };
  }
}

defineProps<BoxComponentProps>();
</script>